class User < ActiveRecord::Base
  ### Associations
  has_many :reminders

  ### Validations
  validates_presence_of :timezone

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :timezone, :confirmation_email


  def self.find_or_invite(email)
    user = User.find_by_email(email.from.first.to_s) || User.invite!(email: email.from.first.to_s,
                                                                     timezone: email.date.zone)
  end

  def active?
    return true if !invitation_token || invitation_accepted_at
  end
end
