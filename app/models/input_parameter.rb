class InputParameter < ActiveRecord::Base
  after_validation :create_fields
  require 'json'
  require 'awesome_print'

  has_many :fields
  belongs_to :algorithm

  validates :input_type, presence: true


  def create_fields
    p 'yolo'
    data = JSON.parse(File.read(Rails.root.join('input-number.json')))
    data = data[input_type]
    data['properties'].each do |k, v|
      create_recurive_field(self,k,v)
    end
  end

  def create_recurive_field(parent,k,v)
    p "Create #{k} with type #{v['type']}"
    params = class_name_for_type(v['type']).constantize.create_from_hash(k, v)
    field = class_name_for_type(v['type']).constantize.create!(params)
    parent.fields << field
    if v.has_key?('properties')
      v['properties'].each do |k, v|
        create_recurive_field(field,k,v)
      end
    end
  end

  def class_name_for_type(type)
    case(type)
    when 'number'
      'NumberField'
    when 'string'
      'StringField'
    when 'object'
      'ObjectField'
    when 'boolean'
      'BooleanField'
    end
  end

end
