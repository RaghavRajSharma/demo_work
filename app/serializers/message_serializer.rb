# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  sender_id       :string(255)
#  content         :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  conversation_id :integer
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#

class MessageSerializer < ActiveModel::Serializer
  attributes :id, :sender, :content, :created_at, :last_activity

  def sender
    {
      display_name: PersonViewUtils.person_display_name(Person.find_by(id: object.sender_id), object.conversation.community),
      image_url: Person.find_by(id: object.sender_id).image.present? ? Person.find_by(id: object.sender_id)&.image&.url(:thumb) : "https://theflyingflea.com/assets/profile_image/thumb/missing.png",
      profile_path: person_url(username: object.sender.username)
    }
  end

  def last_activity
    ApplicationController.helpers.time_ago_in_words(object.created_at) + " ago"
  end
end
