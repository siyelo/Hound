class FetchedMail < ActiveRecord::Base
  belongs_to :user
  has_many :reminders

  attr_accessible :to, :from, :subject, :body, :cc, :bcc, :user, :message_id,
    :in_reply_to
  serialize :to, Array
  serialize :cc, Array
  serialize :bcc, Array

  # Validations
  validates :from, presence: true
  validates :to, presence: true
  validates :user, presence: true
  validates :message_id, uniqueness: true

  def self.create_from_mail!(mail = Mail.new, user)
    fetched_mail = FetchedMail.new(user: user)
    fetched_mail.from_mail(mail)
    fetched_mail.save!
    fetched_mail
  end

  def from_mail(mail = Mail.new)
    self.subject = mail.subject
    self.body = EmailBodyParser.extract_html_or_text_from_body(mail)
    self.from = mail.from.first.to_s if mail.from
    
    [:to, :cc, :bcc].each do |m|
      self.send("#{m}=", mail.send(m) || [])
    end

    [:subject, :message_id, :in_reply_to].each do |m|
      self.send("#{m}=", mail.send(m))
    end
    self
  end

  def body
    Base64::decode64(read_attribute(:body))
  end

  def body=(value)
    write_attribute(:body, Base64::encode64(value || ''))
  end

  # this could be persisted with awesome_nested_set
  # however we found this issue
  # https://github.com/collectiveidea/awesome_nested_set/issues/121
  # so we use a lookup instead, if a reply_to id is present
  def parent
    in_reply_to? ? self.class.where(message_id: in_reply_to).first : nil 
  end

  def all_addresses
    to.to_a + cc.to_a + bcc.to_a
  end
end
# == Schema Information
#
# Table name: fetched_mails
#
#  id          :integer         not null, primary key
#  from        :string(255)
#  to          :string(255)
#  cc          :string(255)
#  bcc         :string(255)
#  subject     :string(255)
#  body        :string(255)
#  user_id     :integer
#  message_id  :string(255)     indexed
#  in_reply_to :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

