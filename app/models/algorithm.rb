class Algorithm < ActiveRecord::Base

  has_one :algorithm_info
  has_many :input_parameters
  belongs_to :user

  accepts_nested_attributes_for :algorithm_info, allow_destroy: :true
  accepts_nested_attributes_for :input_parameters, allow_destroy: :true

  validates :name, presence: true
  validates :namespace, presence: true
  validates :description, presence: true
  #validates :algorithm_info, presence: true
end
