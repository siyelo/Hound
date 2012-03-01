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
    joins("left outer join email_aliases on email_aliases.user_id = users.id").
    where("email_aliases.email = ? OR users.email = ?", email, email).
    group("users.id").first
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
    self.modify_token = Digest::SHA1.hexdigest("#{email} #{rand(1000)}")
  end

  def all_email_addresses
    aliases.map { |a| a.email } << email
  end

end
