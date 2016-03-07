class InputParameter < ActiveRecord::Base
  after_validation :create_fields, if: 'self.errors.empty?'
  require 'json'

  has_many :fields, as: :fieldable, dependent: :destroy
  belongs_to :algorithm

  validates :input_type, presence: { :unless => (input_type = "")}, if: :done_or_step_2?

  accepts_nested_attributes_for :fields, allow_destroy: :true

  def done_or_step_2?
    self.algorithm.parameters? || self.algorithm.done?
    return true
  end

  def all_fields
    found_fields = Array.new
    self.fields.each do |field|
      found_fields << field
      found_fields = found_fields + field.all_fields if field.type == 'ObjectField'
    end
    found_fields
  end

  def create_fields
    return unless self.fields.empty?
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

  def self.available_input_types
    #TODO parse input_types directly from API
    data = JSON.parse(File.read(Rails.root.join('input_types.json')))
    [*data.keys]
  end

end
