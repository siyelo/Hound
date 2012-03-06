class MessageThread < ActiveRecord::Base
  acts_as_nested_set

  ### Associations
  has_many :reminders

  ### Attributes
  attr_accessible :message_id, :parent_id, :parent

  ### Instance methods
  def hound_recipients
    self.reminders.map{ |r| r.sent_to }
  end

  def last_message_id
    self.leaves.empty? ? self.message_id : self.leaves.last.message_id
  end
end
# == Schema Information
#
# Table name: message_threads
#
#  id         :integer         not null, primary key
#  message_id :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  lft        :integer
#  rgt        :integer
#  depth      :integer
#  parent_id  :integer
#

