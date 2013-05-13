class FetchedMail < ActiveRecord::Base

  ### Associations
  belongs_to :user
  has_many :reminders, dependent: :destroy

  ### Attributes
  attr_accessible :to, :from, :subject, :body, :cc, :bcc, :user, :message_id,
                  :in_reply_to

  ### Serialized attributes
  serialize :to,  Array
  serialize :cc,  Array
  serialize :bcc, Array

  ### Validations
  validates :from, presence: true
  validates :to, presence: true
  validates :user, presence: true
  validates :message_id, uniqueness: true

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

  def body=(value)
    write_attribute(:body, value ? value.unpack("C*").pack("U*") : '')
  end

  def cc=(cc_string_or_array)
    write_attribute(:cc, EmailList.new(cc_string_or_array).to_a)
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

  def self.create_from_mail!(mail = Mail.new, user)
    fetched_mail = FetchedMail.new(user: user)
    fetched_mail.from_mail(mail)
    fetched_mail.save!
    fetched_mail
  end
end

# == Schema Information
#
# Table name: fetched_mails
#
#  id          :integer         not null, primary key
#  from        :text
#  to          :text
#  cc          :text
#  bcc         :text
#  subject     :text
#  body        :text
#  user_id     :integer         indexed
#  message_id  :string(255)     indexed
#  in_reply_to :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

