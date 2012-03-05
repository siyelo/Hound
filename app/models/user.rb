class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  ### Associations
  has_many :reminders
  has_many :email_aliases

  ### Callbacks
  before_validation :generate_new_token, on: :create

  ### Validations
  validates_presence_of :timezone
  validates_with EmailValidator

  attr_accessible :email, :password, :remember_me,
    :timezone, :confirmation_email, :modify_token

  ### Class methods
  def self.find_or_invite(email)
    from = email.from.first.to_s
    time_zone = ActiveSupport::TimeZone[email.date.zone.to_i].name
    user = User.find_by_email_or_alias(from) ||
      User.invite!(email: from, timezone: time_zone) {|u| u.skip_invitation = true}
  end

  def self.find_by_email_or_alias(email)
    where("users.email = ? OR 
           users.id = (SELECT em.user_id
                       FROM email_aliases em
                       WHERE em.email = ?)", email, email).
    readonly(false).first
  end

  #overwrite Devise finder - allow user to login with
  #primary or alias email address
  def self.find_for_database_authentication(conditions={})
    self.find_by_email_or_alias(conditions[:email])
  end

  ### Instance methods
  def active?
    return true if !invitation_token || invitation_accepted_at
  end

  def confirmation_email=(value)
    value = normalize_boolean(value)
    generate_new_token if value
    write_attribute(:confirmation_email, value)
  end

  def normalize_boolean(value)
    value == true || value == "1"
  end

  def toggle_confirmation_email(token)
    if token == modify_token
      self.confirmation_email = false
      self.modify_token = nil
      self.save
    end
  end

  def generate_new_token
    self.modify_token = Token.new
  end

  def all_email_addresses
    aliases.map { |a| a.email } << email
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

