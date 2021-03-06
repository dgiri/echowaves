# == Schema Info
# Schema version: 20090906125449
#
# Table name: subscriptions
#
#  id              :integer(4)      not null, primary key
#  conversation_id :integer(4)
#  last_message_id :integer(4)      default(0)
#  user_id         :integer(4)
#  activated_at    :datetime
#  created_at      :datetime
#  updated_at      :datetime

class Subscription < ActiveRecord::Base

  belongs_to :user, :counter_cache => true
  belongs_to :conversation, :counter_cache => true

  validates_presence_of :user_id, :conversation_id

  def new_messages_count
    self.conversation.messages.count :conditions => ["id > ?", self.last_message_id]
  end

  def mark_read!(last_message_id=nil)
    if last_message_id
      self.update_attributes(:last_message_id => last_message_id)
    else
      self.update_attributes(:last_message_id => self.conversation.messages.last.id) unless self.conversation.messages.count == 0
    end
  end

  def activate!
    self.mark_read!
    self.touch(:activated_at)
  end

  # for use in json and xml serialization
  def convo_name
    self.conversation.name
  end

end
