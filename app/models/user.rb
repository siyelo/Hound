class User < ActiveRecord::Base
  ### Associations
  has_many :reminders

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me

  def self.find_or_invite(email)
    user = User.find_by_email(email) || User.invite!(email: email)
  end
end
