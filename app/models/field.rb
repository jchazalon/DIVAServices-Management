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
    data = Hash.new
    self.fields.each do |field| #TODO why fields??? copy paste error from input parameters?
      if field.type == 'ObjectField'
        data[field.name] = field.to_schema
      else
        data[field.name] = field.value_to_schema unless field.value.blank?
      end
    end
    return data
  end

  def deep_copy
    if self.type == 'ObjectField'
      field_copy = self.dup
      self.fields.each do |field|
        field_copy.fields << field.deep_copy
      end
      field_copy.save!
      field_copy
    else
      field_copy = self.dup
      field_copy.save!
      field_copy
    end
  end

  def anything_changed?
    if self.type == 'ObjectField'
      self.fields.each do |field|
        return true if field.anything_changed?
      end
    else
      return true if self.changed?
    end
    return false;
  end

  def value_to_schema
    self.value
  end
end
