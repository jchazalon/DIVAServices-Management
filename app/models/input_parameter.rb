class InputParameter < ActiveRecord::Base
  after_validation :create_fields
  require 'json'

  has_many :fields
  belongs_to :algorithm

  validates :input_type, presence: true

  accepts_nested_attributes_for :fields, allow_destroy: :true


  def create_fields
    #TODO parse input_types directly from API
    data = JSON.parse(File.read(Rails.root.join('input_types.json')))
    data = data[self.input_type]
    data['properties'].each do |k, v|
      create_recurive_field(self,k,v)
    end
  end

  def create_recurive_field(parent,k,v)
    p "Create #{k} with type #{v['type']}".concat((parent == self ? " " : " in #{parent.name}"))
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
    "#{type.capitalize}Field"
  end

  def self.possible_input_types
    #TODO parse input_types directly from API
    data = JSON.parse(File.read(Rails.root.join('input_types.json')))
    [*data.keys]
  end

end
