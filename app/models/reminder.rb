class Reminder < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :email, :subject


  def self.parse_email(email)
    regex = /((\d+)([a-z]+))/
    result = email.scan regex
    result.sum { |r| r[1].to_i.send(r[2]) }.from_now
  end
end
