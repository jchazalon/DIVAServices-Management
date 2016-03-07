class Field < ActiveRecord::Base

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

  #TODO Add server-side validations only on user actions!
  #validates :value, presence: true, if: 'self.required && self.persisted?'

  def self.create_from_hash(k,v)
    params = Hash.new
    params['value'] = ''
    params['name'] = k
    params['infoText'] = v['infoText']
    params['required'] = v['required']
    return params
  end

end
