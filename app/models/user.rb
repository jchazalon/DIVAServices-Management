class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :algorithms, dependent: :destroy

  def admin?
    self.admin
  end

  def algorithms
    if self.admin?
      Algorithm.all
    else
      Algorithm.where(user: self)
    end
  end
end
