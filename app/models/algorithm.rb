class Algorithm < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  require 'zip'

  def self.wizard_steps
    [:informations, :parameters, :parameters_details, :upload, :review]
  end

  enum creation_status: [:empty, *Algorithm.wizard_steps, :validating, :building, :published, :deactivated, :error]

  mount_uploader :zip_file, AlgorithmUploader

  after_validation :create_fields, if: 'self.errors.empty? && self.fields.empty?'

  has_many :fields, as: :fieldable, dependent: :destroy
  has_many :input_parameters, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :fields, allow_destroy: :true
  accepts_nested_attributes_for :input_parameters, allow_destroy: :true

  validates :creation_status, presence: true
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9\s]+\z/, message: "cannot contain any special characters" }, if: :review_or_step_1?
  validates :namespace, presence: true, format: { with: /\A[a-zA-Z0-9\s]+\z/, message: "cannot contain any special characters" }, if: :review_or_step_1?
  validates :description, presence: true, if: :review_or_step_1?
  #TODO validate required additional_information fields

  validates :output, presence: true, inclusion: { in: DivaServiceApi.available_output_types.values.map(&:to_s) }, if: :review_or_step_2?

  validates :zip_file, presence: true, file_size: { less_than: 100.megabytes }, if: :review_or_step_4?
  validates_integrity_of :zip_file, if: :review_or_step_4?
  validates_processing_of :zip_file, if: :review_or_step_4?
  validates :executable_path, presence: true, format: { with: /\A[a-zA-Z0-9\.\-\s\/\_]+\z/, message: "contains invalid characters" }, if: :review_or_step_4?
  validate :valid_zip_file, if: :review_or_step_4?
  validate :zip_file_includes_executable_path, if: :review_or_step_4?
  validate :executable_path_is_a_file, if: :review_or_step_4?
  validates :environment, presence: true, inclusion: { in: DivaServiceApi.available_environments.values.map(&:to_s) }, if: :review_or_step_4?

  def review_or_step_1?
    informations? || review?
  end

  def review_or_step_2?
    parameters? || review?
  end

  def review_or_step_3?
    parameters_details? || review?
  end

  def review_or_step_4?
    upload? || review?
  end

  def finished_wizard?
    validating? || building? || published? || deactivated? || error?
  end

  def valid_zip_file
    begin
      zip = Zip::File.open(self.zip_file.file.file)
    rescue StandardError
      errors.add(:zip_file, 'is not a valid zip')
    ensure
      zip.close if zip
    end
  end

  def zip_file_includes_executable_path
    begin
      zip = Zip::File.open(self.zip_file.file.file)
      errors.add(:zip_file, "doesn't contain the executable '#{self.executable_path}'") unless zip.find_entry(self.executable_path)
    rescue StandardError
      errors.add(:zip_file, 'is not a valid zip')
    ensure
      zip.close if zip
    end
  end

  def executable_path_is_a_file
    begin
      zip = Zip::File.open(self.zip_file.file.file)
      errors.add(:executable_path, "doesn't point to a file") unless zip.find_entry(self.executable_path).ftype == :file
    rescue StandardError
      errors.add(:zip_file, 'is not a valid zip')
    ensure
      zip.close if zip
    end
  end

  def image_name
    "#{self.name.downcase.tr(' ', '_')}:1.0"
  end

  @@current_input_parameter_position = 0

  def next_input_parameter_position
    @@current_input_parameter_position += 1
  end

  def additional_information_with(name)
    fields = Field.where(fieldable_id: self.id)#, fieldable_type: result.class.name)
    field = fields.where("payload->>'name' = ?", name).first
  end

  def zip_url
     root_url[0..-2] + self.zip_file.url if self.zip_file.file
  end

  def to_schema
    additional_information = self.fields.map{ |field| {field.name => field.value} unless field.value.blank? }.compact.reduce(:merge) || {}
    inputs = Array.new
    self.input_parameters.each do |input_parameter|
      inputs << { input_parameter.input_type => input_parameter.to_schema }
    end
    { name: self.name,
      image_name: self.image_name,
      namespace: self.namespace,
      description: self.description.gsub("\r\n", ' '),
      info: additional_information,
      input: inputs,
      output: self.output,
      file: self.zip_url,
      executable: self.executable_path,
      base_image: self.environment
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
