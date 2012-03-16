class FetchedMail

  include Mongoid::Document
  include Mongoid::Timestamps

  field :from,        type: String
  field :to,          type: Array
  field :cc,          type: Array
  field :bcc,         type: Array
  field :subject,     type: String
  field :body,        type: String
  field :message_id,  type: String
  field :in_reply_to, type: String

  embeds_many :reminders
  embedded_in :user

  attr_accessible :to, :from, :subject, :body, :cc, :bcc, :user, :message_id,
    :in_reply_to

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

  def is_address_bcc?(address)
    bcc.include? address
  end
end
# == Schema Information
#
# Table name: fetched_mails
#
#  id         :integer         not null, primary key
#  from       :string(255)
#  to         :string(255)
#  cc         :string(255)
#  bcc        :string(255)
#  subject    :string(255)
#  body       :string(255)
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

