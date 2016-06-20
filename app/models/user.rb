##
# User class provided by a gem called {devise}[https://github.com/plataformatec/devise].
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :algorithms, dependent: :destroy

  ##
  # True if the current user is an administrator.
  def admin?
    self.admin
  end

  ##
  # Returns all owned algorithms of the user.
  # If the user is an administrator, all algorithms are returned.
  def algorithms
    if self.admin?
      Algorithm.all
    else
      Algorithm.where(user: self)
    end
  end
end
