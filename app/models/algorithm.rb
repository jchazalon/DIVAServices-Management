##
# Defines what an _algorithm_ consits of and implements all its actions.
class Algorithm < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  require 'zip'
  default_scope { order('updated_at DESC') }

  ##
  # Defines the subset of statuses that are considered as wizard steps as well.
  def self.wizard_steps
    [:informations, :parameters, :parameters_details, :upload, :review]
  end

  # All statuses an _algorithm_ can have
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

  # --------------------------------------
  # :section: Validation methods
  # --------------------------------------

  ##
  # Validates that there is no virus inside the uploaded file.
  def check_for_virus
    if self.zip_file.file.present?
      if !ClamScan::Client.scan(location: self.zip_file.path).safe?
        File.delete(self.zip_file.file.path)
        errors.add(:zip_file, 'Please don\'t upload any viruses')
      end
    end
  end

  ##
  # Validates that the uploaded file is a valid zip file.
  def valid_zip_file
    begin
      zip = Zip::File.open(self.zip_file.file.file)
    rescue StandardError => e
      errors.add(:zip_file, "is not a valid zip.\nError: #{e}")
    ensure
      zip.close if zip
    end
  end

  ##
  # Validates that the uploaded archive contains the executable file declared in _executable path_.
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

  ##
  # Validates that the the executable file declared in _executable path_ is a file.
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

  # --------------------------------------
  # :section: Status checks
  # --------------------------------------

  ##
  # Returns true if the upload should be validated.
  def validate_upload?
    upload? || review? || published? || unpublished_changes?
  end

  ##
  # Returns true if the publication is currently pending.
  def publication_pending?
    validating? || creating? || testing?
  end

  ##
  # Returns true if the wizard is already finished.
  def finished_wizard?
    !empty? && !informations? && !parameters? && !parameters_details? && !upload? && !review?
  end

  ##
  # Returns true if the _algorithm_ is already published.
  def already_published?
    return false if Algorithm.where(next: self).empty? # Algorithm has no predecessor yet
    return true
  end

  # --------------------------------------
  # :section: General
  # --------------------------------------

  ##
  # Returns the previous version of the current _algorithm_.
  def predecessor
    Algorithm.where(next: self).first
  end

  ##
  # Updates the status and (optionally) status message of the _algorithm_.
  # It is extremly important that the status is only changed via this method!
  def set_status(status, status_message = '')
    return if status == Algorithm.statuses[self.status]
    self.update_attributes(status: status)
    self.update_attributes(status_message: status_message)
    self.update_attribute(:diva_id, nil) if self.status == 'review' || self.status == 'unpublished_changes'
    self.update_version if self.status == 'published'
  end

  ##
  # Reverts all unpublished changes by simply creating a new blank copy of the previous version.
  # This method removes the current _algorithm_ instance and creates a new _algorithm_.
  def revert_changes(old_algorithm)
    new_algorithm = old_algorithm.deep_copy
    new_algorithm.update_attributes(next: nil)
    old_algorithm.update_attributes(next: new_algorithm)
    self.destroy
    new_algorithm.update_attributes(status: :published)
    new_algorithm.update_attributes(status_message: "Algorithm is published")
    new_algorithm
  end

  @@current_input_parameter_position = 0

  def next_input_parameter_position
    @@current_input_parameter_position += 1
  end

  ##
  # Virtual accessor for the name field, because it is used very often.
  def name
    self.general_fields.where(fieldable_id: self.id).where("payload->>'key' = 'name'").first.value
  end

  ##
  # Used to access a general field.
  def general_field(name)
    self.general_fields.where(fieldable_id: self.id).where("payload->>'key' = ?", name).first
  end

  ##
  # Used to access a output field.
  def output_field(name)
    self.output_fields.where(fieldable_id: self.id).where("payload->>'key' = ?", name).first
  end

  ##
  # Used to access a method field.
  def method_field(name)
    self.method_fields.where(fieldable_id: self.id).where("payload->>'key' = ?", name).first
  end

  ##
  # Gets the current status.
  # If the optional parameter _update_ is set true, the current status of the DIVAServices is fetched.
  def status(update = false)
    if update
      diva_algorithm = DivaServicesApi::Algorithm.by_id(self.diva_id)
      if diva_algorithm
        self.set_status(diva_algorithm.status_code, diva_algorithm.status_message)
      end
    end
    super()
  end

  ##
  # Returns the number of executions of the _algorithm_.
  def execution_count
    diva_algorithm = DivaServicesApi::Algorithm.by_id(self.diva_id)
    if diva_algorithm
      diva_algorithm.executions
    else
      0
    end
  end

  ##
  # Returns an array containing all passed exceptions of the _algorithm_.
  def exceptions
    diva_algorithm = DivaServicesApi::Algorithm.by_id(self.diva_id)
    if diva_algorithm
      diva_algorithm.exceptions
    else
      Array.new
    end
  end

  ##
  # Returns the URL of the uploaded zip file.
  def zip_url
    #TODO Pretty sure that will break in production (since root_url isn't set)
    root_url[0..-2] + self.zip_file.url if self.zip_file.file
  end

  ##
  # Generates a json version of the current _algorithm_.
  def to_schema
    { general: self.general_fields.map{ |field| {field.key => field.value} unless field.value.blank? }.compact.reduce(:merge) || {},
      input: self.input_parameters.map{ |input_parameter| { input_parameter.input_type => input_parameter.to_schema } } || [],
      output: self.output_fields.map{ |field| {field.key => field.value} unless field.value.blank? }.compact.reduce(:merge) || {},
      method: {file: self.zip_url}.merge!(self.method_fields.map{ |field| {field.key => field.value} unless field.value.blank? }.compact.reduce(:merge) || {})
    }.to_json
  end

  ##
  # Returns true if any field or value of the _algorithm_ changed since the last save.
  def anything_changed?
    self.changed? || collection_anything_changed([self.general_fields, self.input_parameters, self.output_fields, self.method_fields])
  end

  protected

  ##
  # Creates a new version of the _algorithm_ and adds it as the successor to the current one.
  def update_version
    self.update_attributes(version: self.version + 1)
    new_algorithm = self.deep_copy
    self.update_attributes(next: new_algorithm)
    new_algorithm
  end

  ##
  # Creates a full deep copy of the current _algorithm_ including every field and value.
  # Also copys the uploaded file.
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

  ##
  # Generic method to check if any field inside a collection has changed.
  def collection_anything_changed(collections)
    collections.each do |collection|
      collection.each do |field|
        return true if field.anything_changed?
      end
    end
  end

  ##
  # Creates all necessary fields as ordered by the DIVAServices.
  def create_fields
    create_fields_of(DivaServicesApi::Algorithm.general_information, :general)
    create_fields_of(DivaServicesApi::Algorithm.output_information, :output)
    create_fields_of(DivaServicesApi::Algorithm.method_information, :method)
  end

  ##
  # Creates all necessary fields of the current category as ordered by the DIVAServices.
  def create_fields_of(data, category)
    data.each do |k, v|
      params = Field.class_name_for_type(v['type']).constantize.create_from_hash(k, v)
      params.merge!(category: category)
      field = Field.class_name_for_type(v['type']).constantize.create!(params)
      self.general_fields << field #NOTE Since we have already created the object, the category attribute will not change if we add it to the incorrect set of fields. Hence, just add all to general_fields
    end
  end
end
