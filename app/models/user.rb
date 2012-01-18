class User < ActiveRecord::Base
  ### Associations
  has_many :reminders

  ### Validations
  validates_presence_of :timezone

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :timezone


  def self.find_or_invite(email)
    user = User.find_by_email(email) || User.invite!(email: email)
  end

  def active?
    return true if !invitation_token || invitation_accepted_at
  end
end
