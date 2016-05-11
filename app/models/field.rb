class Field < ActiveRecord::Base
  default_scope { order('created_at ASC') }

  belongs_to :field, polymorphic: true

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

  def self.content_attributes
    @@content_attributes ||= {}
  end

  content_attr :value, :string
  content_attr :name, :string
  content_attr :infoText, :text
  content_attr :required, :boolean

  #TODO Server-side validations are almost impossible since we should only run validation on user-actions, but not on server creation and updates...
  #validates :value, presence: true, if: 'self.required', on: :update #This wont work since it also validates after server actions!
  #It would be nice to validate value on server-side. However, it's not necessary, since we peform a DIVAServices validation anyway
  validates :name, presence: true

  def self.create_from_hash(k,v)
    params = Hash.new
    params['value'] = ''
    params['name'] = k
    params['infoText'] = v['infoText']
    params['required'] = v['required']
    return params
  end

  def self.class_name_for_type(type)
    "#{type.capitalize}Field"
  end

  def to_schema
    self.value_to_schema unless self.value.blank?
  end

  def deep_copy
    field_copy = self.dup
    field_copy.save!
    field_copy
  end

  def anything_changed?
    self.changed?;
  end

  def value_to_schema
    self.value
  end
end
