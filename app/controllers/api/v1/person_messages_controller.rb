class Api::V1::PersonMessagesController < Api::V1::BaseController
  swagger_controller :person_messages, 'Person Message'

  swagger_api :create do
    summary "creates person conversation"
    notes "created direct conversation between two persons."
    param :query, :recipient_id, :string, :required, "Username of recipient"
    param :form, :content, :string, :required, "Message Content"
    param :form, :sender_id, :string, :required, "Sender Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end 

  def create
    recipient = Person.find_by!(username: params[:recipient_id], community_id: current_community.id)
    if recipient.present?
      sender = Person.find_by!(id: params[:sender_id])
      if sender.present?
        if sender == recipient
          render json: {error: t("layouts.notifications.you_cannot_send_message_to_yourself")}, status: 404
        else
          conversation = Conversation.new(community_id: current_community.id)
          conversation.build_starter_participation(sender)
          conversation.build_participation(recipient)
          message = conversation.messages.build(content: params[:content], sender_id: params[:sender_id])
          if conversation.save && message.save
            conversation.update(last_message_at: Time.now)
            Delayed::Job.enqueue(MessageSentJob.new(conversation.messages.last.id, current_community.id))
            render json: {conversation: conversation, message: message.content}, status: 200
          else
            render json: {error: conversation.errors.full_messages.to_sentence}, status: 404
          end
        end
      else
        render json: {error: "Sender not found."}, status: 404
      end
    else
      render json: {error: "Recipient not found"}, status: 404
    end 
  end  
end
