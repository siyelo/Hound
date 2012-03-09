class FetchedMail < ActiveRecord::Base
  belongs_to :user

  attr_accessible :to, :from, :subject, :body, :cc, :bcc
  serialize :to, Array
  serialize :cc, Array
  serialize :bcc, Array

  # Validations
  validates :from, presence: true
  validates :to, presence: true
  validates :body, presence: true
  validates :user, presence: true

  def from_mail(mail = Mail.new)
    self.to = mail.to
    self.from = mail.from.first.to_s if mail.from
    self.subject = mail.subject
    self.body = EmailBodyParser.extract_html_or_text_from_body(mail)
    self.cc = mail.cc || []
    self.bcc = mail.bcc || []
  end

  #def to_hound
    #all_addresses.select{ |t| t.include?('@hound.cc') }
  #end

  #def not_to_hound
    #all_addresses.select{ |t| !t.include?('@hound.cc') }
  #end

  #def all_addresses
    #to + cc + bcc + [from]
  #end
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

