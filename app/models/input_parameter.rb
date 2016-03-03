class InputParameter < ActiveRecord::Base

  has_many :fields
  belongs_to :algorithm

  validates :input_type, presence: true

end
