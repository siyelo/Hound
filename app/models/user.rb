class User < ActiveRecord::Base
  ### Associations
  has_many :reminders

  ### Callbacks
  after_create :generate_new_token

  ### Validations
  validates_presence_of :timezone

  devise :invitable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :timezone, :confirmation_email, :modify_token

  ### Class methods
  def self.find_or_invite(email)
    user = User.find_by_email(email.from.first.to_s) || User.invite!(email: email.from.first.to_s,
                                                                     timezone: email.date.zone)
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
    self.save
  end
end
