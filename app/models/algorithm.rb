class Algorithm < ActiveRecord::Base
  mount_uploader :zip_file, AlgorithmUploader

  after_validation :create_fields, if: 'self.errors.empty? && self.fields.empty?'

  has_many :fields, as: :fieldable, dependent: :destroy
  has_many :input_parameters, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :fields, allow_destroy: :true
  accepts_nested_attributes_for :input_parameters, allow_destroy: :true

  def self.steps
    [:informations, :parameters, :parameters_details, :upload]
  end

  enum creation_status: [:empty, *Algorithm.steps, :done]

  validates :name, presence: true, if: :done_or_step_1?
  validates :namespace, presence: true, if: :done_or_step_1?
  validates :description, presence: true, if: :done_or_step_1?
  #TODO validate required additional_information fields
  validates :output, presence: true, if: :done_or_step_2?
  validates :zip_file, presence: true, if: :done_or_step_4?
  validates :language, presence: true, if: :done_or_step_4?

  def done_or_step_1?
    informations? || done?
  end

  def done_or_step_2?
    parameters? || done?
  end

  def done_or_step_3?
    parameters_details? || done?
  end

  def done_or_step_4?
    upload? || done?
  end

  def additional_information_with(name)
    fields = Field.where(fieldable_id: self.id)#, fieldable_type: result.class.name)
    field = fields.where("payload->>'name' = ?", name).first
  end

  def to_schema
    additional_information = self.fields.map{ |field| {field.name => field.value} unless field.value.blank? }.compact!.reduce(:merge) || {}
    inputs = Array.new
    self.input_parameters.each do |input_parameter|
      inputs << { input_parameter.input_type => input_parameter.to_schema }
    end
    { name: self.name,
      description: self.description,
      info: additional_information,
      input: inputs,
      output: self.output
    }.to_json
  end

  private

  def create_fields
    data = DivaServiceApi.additional_information
    data.each do |k, v|
      params = Field.class_name_for_type(v['type']).constantize.create_from_hash(k, v)
      field = Field.class_name_for_type(v['type']).constantize.create!(params)
      self.fields << field
    end
  end
end
