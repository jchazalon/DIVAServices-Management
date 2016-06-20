##
# Abstract implementation of a field that can hold information as provided by the DIVAServices.
class Field < ActiveRecord::Base
  default_scope { order('created_at ASC') }

  belongs_to :field, polymorphic: true

  ##
  # Adds dynamically virtual getter and setter methods for all attributes set by using +content_attr+.
  # Stores the values direct inside a json field of the Postgres DB called _payload_.
  def self.content_attr(attr_name, attr_type = :string)
    content_attributes[attr_name] = attr_type

    define_method(attr_name) do
      self.payload ||= {}
      self.payload[attr_name.to_s]
    end

    define_method("#{attr_name}=".to_sym) do |value|
      self.payload ||= {}
      self.payload[attr_name.to_s] = value
      self.payload_will_change!
      self.save
    end
  end

  ##
  # Lists all available virtual attribites.
  def self.content_attributes
    @@content_attributes ||= {}
  end

  content_attr :key, :string
  content_attr :value, :string
  content_attr :name, :string
  content_attr :infoText, :text
  content_attr :required, :boolean

  # Server-side validations are impossible, since we should only run validation on user-actions, but not on server creation and updates.
  # For example +validates :value, presence: true, if: 'self.required', on: :update+ won't work since it also validates after server actions, where some information may not be valid yet!
  # It would be nice to validate value on server-side. However, it's not necessary, since we peform a DIVAServices validation anyway.
  validates :name, presence: true

  ##
  # Builds a param that is necessary to create the object.
  def self.create_from_hash(k,v)
    params = Hash.new
    params['key'] = k
    params['value'] = ''
    params['name'] = v['displayText']
    params['name'] ||= k
    params['infoText'] = v['infoText']
    params['required'] = v['required']
    return params
  end

  ##
  # Defines what form of field is used.
  def self.class_name_for_type(type)
    "#{type.capitalize}Field"
  end

  ##
  # Transforms the field to json
  def to_schema
    self.value_to_schema unless self.value.blank?
  end

  ##
  # Created a deep copy of the field.
  def deep_copy
    field_copy = self.dup
    field_copy.save!
    field_copy
  end

  ##
  # Checks if any value of the field has changed.
  def anything_changed?
    self.changed?;
  end

  def value_to_schema
    self.value
  end
end
