class MessageThread < ActiveRecord::Base
  acts_as_tree

  attr_accessible :message_id, :parent_id, :parent

  has_many :reminders

  def hound_recipients
    self.reminders.map{ |r| r.sent_to }
  end
end
