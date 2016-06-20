class Algorithm < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  require 'zip'
  default_scope { order('updated_at DESC') }

  def self.wizard_steps
    [:informations, :parameters, :parameters_details, :upload, :review]
  end

  enum status: { empty: 0, validating: 50, unpublished_changes: 51, creating: 100, testing: 110, published: 200, validation_error: 412, error: 500, connection_error: 503 }.merge!(Hash[ Algorithm.wizard_steps.map{ |c| [c, Algorithm.wizard_steps.index(c) + 1] } ])

  mount_uploader :zip_file, AlgorithmUploader

  after_validation :create_fields, if: 'self.errors.empty? && self.general_fields.empty?'

  belongs_to :next, class_name: 'Algorithm', dependent: :destroy
  belongs_to :user

  has_many :general_fields, -> { where category: :general }, class_name: 'Field', as: :fieldable, dependent: :destroy
  has_many :input_parameters, dependent: :destroy
  has_many :output_fields, -> { where category: :output }, class_name: 'Field', as: :fieldable, dependent: :destroy
  has_many :method_fields, -> { where category: :method }, class_name: 'Field', as: :fieldable, dependent: :destroy

  accepts_nested_attributes_for :general_fields, allow_destroy: :true
  accepts_nested_attributes_for :input_parameters, allow_destroy: :true
  accepts_nested_attributes_for :output_fields, allow_destroy: :true
  accepts_nested_attributes_for :method_fields, allow_destroy: :true

  validates :status, presence: true

  validates :zip_file, presence: true, file_size: { less_than: 100.megabytes }, if: :validate_upload?
  validates_integrity_of :zip_file, if: :validate_upload?
  validates_processing_of :zip_file, if: :validate_upload?
  validate :valid_zip_file, if: :validate_upload?
  validate :zip_file_includes_executable_path, if: :validate_upload?
  validate :executable_path_is_a_file, if: :validate_upload?
  #validate :check_for_virus #TODO temporally deactivated until not everythin is a virus on production....

  def validate_upload?
    upload? || review? || published? || unpublished_changes?
  end

  def publication_pending?
    validating? || creating? || testing?
  end

  def set_status(status, status_message = '')
    return if status == Algorithm.statuses[self.status]
    self.update_attributes(status: status)
    self.update_attributes(status_message: status_message)
    self.update_version if self.status == 'published'
  end

  def update_version
    self.update_attributes(version: self.version + 1)
    new_algorithm = self.deep_copy
    self.update_attributes(next: new_algorithm)
    new_algorithm
  end

  def deep_copy
    algorithm_copy = self.dup
    self.general_fields.each{ |field| algorithm_copy.general_fields << field.deep_copy }
    self.input_parameters.each{ |input_parameter| algorithm_copy.input_parameters << input_parameter.deep_copy }
    self.output_fields.each{ |field| algorithm_copy.output_fields << field.deep_copy }
    self.method_fields.each{ |field| algorithm_copy.method_fields << field.deep_copy }
    algorithm_copy.save(validate: false) #NOTE Can't do validations before the fields are saved(created!) the first time
    AlgorithmUploader.copy_file(self.id, algorithm_copy.id) #XXX Need to copy the file, since CarrierWave won't do that for us...
    algorithm_copy.save! #NOTE Save it for real!
    algorithm_copy
  end

  def finished_wizard?
    !empty? && !informations? && !parameters? && !parameters_details? && !upload? && !review?
  end

  def already_published?
    return false if self.diva_id.nil? # Algorithm has no id on DIVAServices yet
    return false if Algorithm.where(next: self).empty? # Algorithm has no predecessor yet
    return true
  end

  def check_for_virus
    if self.zip_file.file.present?
      if !ClamScan::Client.scan(location: self.zip_file.path).safe?
        File.delete(self.zip_file.file.path)
        errors.add(:zip_file, 'Please don\'t upload any viruses')
      end
    end
  end

  def valid_zip_file
    begin
      zip = Zip::File.open(self.zip_file.file.file)
    rescue StandardError => e
      errors.add(:zip_file, "is not a valid zip.\nError: #{e}")
    ensure
      zip.close if zip
    end
  end

  def zip_file_includes_executable_path
    begin
      zip = Zip::File.open(self.zip_file.file.file)
      errors.add(:zip_file, "doesn't contain the executable '#{self.method_field('executable_path').value}'") unless zip.find_entry(self.method_field('executable_path').value)
    rescue StandardError => e
      errors.add(:zip_file, "is not a valid zip.\nError: #{e}")
    ensure
      zip.close if zip
    end
  end

  def executable_path_is_a_file
    begin
      zip = Zip::File.open(self.zip_file.file.file)
      errors.add(:executable_path, "doesn't point to a file") unless zip.find_entry(self.method_field('executable_path').value).ftype == :file
    rescue StandardError => e
      errors.add(:zip_file, "is not a valid zip.\nError: #{e}")
    ensure
      zip.close if zip
    end
  end

  @@current_input_parameter_position = 0

  def next_input_parameter_position
    @@current_input_parameter_position += 1
  end

  #NOTE Since the name will be used a lot, we create a virtual accessor
  def name
    self.general_fields.where(fieldable_id: self.id).where("payload->>'key' = 'name'").first.value
  end

  def general_field(name)
    self.general_fields.where(fieldable_id: self.id).where("payload->>'key' = ?", name).first
  end

  def output_field(name)
    self.output_fields.where(fieldable_id: self.id).where("payload->>'key' = ?", name).first
  end

  def method_field(name)
    self.method_fields.where(fieldable_id: self.id).where("payload->>'key' = ?", name).first
  end

  def status(update = false)
    if update
      diva_algorithm = DivaServicesApi::Algorithm.by_id(self.diva_id)
      if diva_algorithm
        self.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
      end
    end
    super()
  end

  def execution_count
    diva_algorithm = DivaServicesApi::Algorithm.by_id(self.diva_id)
    if diva_algorithm
      diva_algorithm.executions
    else
      0
    end
  end

  def exceptions
    diva_algorithm = DivaServicesApi::Algorithm.by_id(self.diva_id)
    if diva_algorithm
      diva_algorithm.exceptions
    else
      Array.new
    end
  end

  #TODO Pretty sure that will break in production (since root_url isn't set)
  def zip_url
     root_url[0..-2] + self.zip_file.url if self.zip_file.file
  end

  def to_schema
    { general: self.general_fields.map{ |field| {field.key => field.value} unless field.value.blank? }.compact.reduce(:merge) || {},
      input: self.input_parameters.map{ |input_parameter| { input_parameter.input_type => input_parameter.to_schema } } || [],
      output: self.output_fields.map{ |field| {field.key => field.value} unless field.value.blank? }.compact.reduce(:merge) || {},
      method: {file: self.zip_url}.merge!(self.method_fields.map{ |field| {field.key => field.value} unless field.value.blank? }.compact.reduce(:merge) || {})
    }.to_json
  end

  def anything_changed?
    self.changed? || collection_anything_changed([self.general_fields, self.input_parameters, self.output_fields, self.method_fields])
  end

  private

  def collection_anything_changed(collections)
    collections.each do |collection|
      collection.each do |field|
        return true if field.anything_changed?
      end
    end
  end

  def create_fields
    create_fields_of(DivaServicesApi::Algorithm.general_information, :general)
    create_fields_of(DivaServicesApi::Algorithm.output_information, :output)
    create_fields_of(DivaServicesApi::Algorithm.method_information, :method)
  end

  def create_fields_of(data, category)
    data.each do |k, v|
      params = Field.class_name_for_type(v['type']).constantize.create_from_hash(k, v)
      params.merge!(category: category)
      field = Field.class_name_for_type(v['type']).constantize.create!(params)
      self.general_fields << field #NOTE Since we have already created the object, the category attribute will not change if we add it to the incorrect set of fields. Hence, just add all to general_fields
    end
  end
end
