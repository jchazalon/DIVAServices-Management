class Algorithm < ActiveRecord::Base
  mount_uploader :zip_file, AlgorithmUploader

  has_one :algorithm_info, dependent: :destroy
  has_many :input_parameters, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :algorithm_info, allow_destroy: :true
  accepts_nested_attributes_for :input_parameters, allow_destroy: :true

  enum creation_status: [:empty, :informations, :parameters, :parameters_details, :upload, :done]

  validates :name, presence: true, if: :done_or_step_1?
  validates :namespace, presence: true, if: :done_or_step_1?
  validates :description, presence: true, if: :done_or_step_1?
  
  #validates :algorithm_info, presence: true

  def done_or_step_1?
    informations? || done?
  end
end
