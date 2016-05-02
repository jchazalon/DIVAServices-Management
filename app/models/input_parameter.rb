class InputParameter < ActiveRecord::Base
  default_scope { order('position ASC') }

  before_validation :set_position, if: 'self.position.nil?'
  after_validation :create_fields, if: 'self.errors.empty? && self.fields.empty?'

  has_many :fields, as: :fieldable, dependent: :destroy
  belongs_to :algorithm

  validates :input_type, presence: { :unless => (input_type = "")}, if: :review_or_step_2?
  validates :position, presence: true, if: :review_or_step_2?

  accepts_nested_attributes_for :fields, allow_destroy: :true

  def review_or_step_2?
    self.algorithm.parameters? || self.algorithm.review?
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

  def set_position
    self.position = self.algorithm.next_input_parameter_position
  end

  def create_fields
    data = DivaServiceApi.input_types
    data = data[self.input_type]
    self.description = data['infoText']
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

  def deep_copy
    input_parameter_copy = self.dup
    self.fields.each do |field|
      input_parameter_copy.fields << field.deep_copy
    end
    input_parameter_copy.save!
    input_parameter_copy
  end

end
