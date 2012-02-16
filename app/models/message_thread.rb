class MessageThread < ActiveRecord::Base
  acts_as_nested_set

  attr_accessible :message_id, :parent_id, :parent

  has_many :reminders

  def hound_recipients
    self.reminders.map{ |r| r.sent_to }
  end

  def last_message_id
    self.leaves.empty? ? self.message_id : self.leaves.last.message_id
  end
end
