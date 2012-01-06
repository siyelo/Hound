class Reminder < ActiveRecord::Base
  validates_presence_of :email, :subject
end
