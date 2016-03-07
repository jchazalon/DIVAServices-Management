class InputParameter < ActiveRecord::Base

  after_validation :create_fields, if: 'self.errors.empty? && self.fields.empty?'

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
    data = DivaServiceApi.input_types
    data = data[self.input_type]
    if data.has_key?('properties')
      data['properties'].each do |k, v|
        create_recurive_field(self,k,v)
      end
    end
  end

  def create_recurive_field(parent,k,v)
    params = Field.class_name_for_type(v['type']).constantize.create_from_hash(k, v)
    field = Field.class_name_for_type(v['type']).constantize.create!(params)
    parent.fields << field
    if v.has_key?('properties')
      v['properties'].each do |k, v|
        create_recurive_field(field,k,v)
      end
    end
  end

  def field_with(name)
    fields = Field.where(fieldable_id: self.id)#, fieldable_type: result.class.name)
    field = fields.where("payload->>'name' = ?", name).first
  end

  def to_schema
    data = Hash.new
    self.fields.each do |field|
      if field.type == 'ObjectField'
        data[field.name] = field.to_schema
      else
        data[field.name] = field.value unless field.value.blank?
      end
    end
    return data
  end
end
