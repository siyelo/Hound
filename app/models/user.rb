class User < ActiveRecord::Base
  include User::UserFinder

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  ### Associations
  has_many :reminders, through: :fetched_mails
  has_many :fetched_mails, dependent: :destroy
  has_many :email_aliases, dependent: :destroy

  ### Callbacks
  before_validation :generate_new_token, on: :create

  ### Validations
  validates_presence_of :timezone
  validates_with EmailValidator

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :timezone, :confirmation_email, :modify_token, :invitation_sent_at

  ### Class methods

  class << self
    def find_by_email_or_alias(email)
      where("users.email = ? OR
             users.id = (SELECT em.user_id
                         FROM email_aliases em
                         WHERE em.email = ?)", email, email).
      readonly(false).first
    end

    #overwrite Devise finder - allow user to login with
    #primary or alias email address
    def find_for_database_authentication(conditions={})
      find_by_email_or_alias(conditions[:email])
    end

    def find_and_validate_password(email_address, password)
      user = User.find_by_email_or_alias(email_address)
      user if user && user.valid_password?(password)
    end

  end

  ### Instance methods

  def active?
    return true if !invitation_token || invitation_accepted_at
  end

  def confirmation_email=(value)
    generate_new_token if value
    write_attribute(:confirmation_email, value)
  end

  def disable_confirmation_emails
    self.confirmation_email = false
    self.modify_token = nil
    self.save
  end

  def generate_new_token
    self.modify_token = Token.new
  end

  def all_email_addresses
    aliases.map { |a| a.email } << email
  end

  # Devise callback to accept invitation if user was invited
  def after_password_reset
    accept_invitation! if invitation_token.present?
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null, indexed
#  encrypted_password     :string(128)     default("")
#  reset_password_token   :string(255)     indexed
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  invitation_token       :string(60)      indexed
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer         indexed
#  invited_by_type        :string(255)
#  timezone               :string(255)
#  confirmation_email     :boolean         default(TRUE)
#  modify_token           :string(255)
#

