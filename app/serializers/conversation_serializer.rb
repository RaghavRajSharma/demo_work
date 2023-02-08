# == Schema Information
#
# Table name: conversations
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  listing_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  last_message_at :datetime
#  community_id    :integer
#
# Indexes
#
#  index_conversations_on_community_id     (community_id)
#  index_conversations_on_last_message_at  (last_message_at)
#  index_conversations_on_listing_id       (listing_id)
#

class ConversationSerializer < ActiveModel::Serializer
  attributes :id
  has_many :messages, :serializer => MessageSerializer
end
