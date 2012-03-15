class User

  include Mongoid::Document
  include Mongoid::Timestamps
  include FindsOrInvitesUsers

  ## Database authenticatable
  field :email,              :type => String, :null => false
  field :encrypted_password, :type => String, :null => false

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  field :invitation_token, type: String
  field :invitation_sent_at, type: DateTime
  field :invitation_accepted_at, type: DateTime
  field :invitation_limit, type: Integer
  field :invited_by_id, type: Integer
  field :invited_by_type, type: String
  field :timezone, type: String
  field :confirmation_email, type: Boolean
  field :modify_token, type: String

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  ### Associations
  embeds_many :reminders
  embeds_many :email_aliases

  ### Callbacks
  before_validation :generate_new_token, on: :create

  ### Validations
  validates_presence_of :timezone
  validates_with EmailValidator

  attr_accessible :email, :password, :remember_me,
    :timezone, :confirmation_email, :modify_token

  ### Class methods

  class << self
    def find_by_email_or_alias(email)
      where(:email => email)
      # where("users.email = ? OR
      #        users.id = (SELECT em.user_id
      #                    FROM email_aliases em
      #                    WHERE em.email = ?)", email, email).
      # readonly(false).first
    end

    #overwrite Devise finder - allow user to login with
    #primary or alias email address
    def find_for_database_authentication(conditions={})
      find_by_email_or_alias(conditions[:email])
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

