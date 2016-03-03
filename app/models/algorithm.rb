class Algorithm < ActiveRecord::Base

  has_one :algorithm_info
  has_many :input_parameters
  belongs_to :user

  validates :name, presence: true
  validates :namespace, presence: true
  validates :description, presence: true
  #validates :algorithm_info, presence: true
end
