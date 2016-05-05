class Algorithm < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  require 'zip'
  default_scope { order('updated_at DESC') }

  def self.wizard_steps
    [:informations, :parameters, :parameters_details, :upload, :review]
  end

  enum status: { empty: 0, validating: 50, unpublished_changes: 51, creating: 100, testing: 110, published: 200, validation_error: 412, error: 500, connection_error: 503 }.merge!(Hash[ Algorithm.wizard_steps.map{ |c| [c, Algorithm.wizard_steps.index(c) + 1] } ])

  mount_uploader :zip_file, AlgorithmUploader

  after_validation :create_fields, if: 'self.errors.empty? && self.fields.empty?'

  belongs_to :next, class_name: 'Algorithm', dependent: :destroy
  has_many :fields, as: :fieldable, dependent: :destroy
  has_many :input_parameters, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :fields, allow_destroy: :true
  accepts_nested_attributes_for :input_parameters, allow_destroy: :true

  validates :status, presence: true
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9\s]+\z/, message: "cannot contain any special characters" }, if: :validate_informations?
  validates :description, presence: true, if: :validate_informations?
  #TODO validate required additional_information fields

  validates :output, presence: true, inclusion: { in: DivaServiceApi.output_types.values.map(&:to_s) }, if: :validate_parameters?

  validates :zip_file, presence: true, file_size: { less_than: 100.megabytes }, if: :validate_upload?
  validates_integrity_of :zip_file, if: :validate_upload?
  validates_processing_of :zip_file, if: :validate_upload?
  validates :executable_path, presence: true, format: { with: /\A[a-zA-Z0-9\.\-\s\/\_]+\z/, message: "contains invalid characters" }, if: :validate_upload?
  validate :valid_zip_file, if: :validate_upload?
  validate :zip_file_includes_executable_path, if: :validate_upload?
  validate :executable_path_is_a_file, if: :validate_upload?
  validates :language, presence: true, inclusion: { in: DivaServiceApi.languages.values.map(&:to_s) }, if: :validate_upload?
  validates :environment, presence: true, inclusion: { in: DivaServiceApi.environments.values.map(&:to_s) }, if: :validate_upload?

  def validate_informations?
    informations? || review? || published? || unpublished_changes?
  end

  def validate_parameters?
    parameters? || review? || published? || unpublished_changes?
  end

  def validate_upload?
    upload? || review? || published? || unpublished_changes?
  end

  def publication_pending?
    creating? || testing?
  end

  def set_status(status, status_message = '')
    self.update_attributes(status: status)
    self.update_attributes(status_message: status_message)
    self.update_version if self.status == 'published'
  end

  def update_version
    self.update_attributes(version: self.version + 1)
    new_algorithm = self.deep_copy
    self.update_attributes(next: new_algorithm)
    return new_algorithm
  end

  def deep_copy
    algorithm_copy = self.dup
    #TODO Need do copy algorithm file as well!!!
    self.fields.each do |field|
      algorithm_copy.fields << field.deep_copy
    end
    self.input_parameters.each do |input_parameter|
      algorithm_copy.input_parameters << input_parameter.deep_copy
    end
    algorithm_copy.save!
    algorithm_copy
  end

  def pull_status
    response = DivaServiceApi.status(self.diva_id)
    if !response.empty? && response['statusCode'] != Algorithm.statuses[self.status]
      self.set_status(response['statusCode'], response['statusMessage'])
    end
  end

  def finished_wizard?
    !empty? && !informations? && !parameters? && !parameters_details? && !upload? && !review?
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
    "#{self.name.downcase.tr(' ', '_')}"
  end

  @@current_input_parameter_position = 0

  def next_input_parameter_position
    @@current_input_parameter_position += 1
  end

  def additional_information_with(name)
    fields = self.fields.where(fieldable_id: self.id)#, fieldable_type: result.class.name)
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
      description: self.description.gsub("\r\n", ' '),
      info: additional_information,
      input: inputs,
      output: self.output,
      file: self.zip_url,
      executable: self.executable_path,
      language: self.language,
      base_image: self.environment
    }.to_json
  end

  def anything_changed?
    return true if self.changed?
    self.fields.each do |field|
      return true if field.anything_changed?
    end
    self.input_parameters.each do |input_parameter|
      return true if input_parameter.anything_changed?
    end
    return false;
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
