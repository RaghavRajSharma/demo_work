class Api::V1::MessagesController < Api::V1::BaseController
  swagger_controller :messages, 'Messages'

  swagger_api :create do
    summary "creates message or message reply"
    notes "This end point can be used to create new message/reply of a existing conversation "
    param :form, :id, :integer, :required, "Id of conversation"
    param :form, :content, :string, :required, "Message Content"
    param :form, :sender_id, :string, :required, "Sender Id as username of person"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end   

  def create
    sender = Person.find_by!(username: params[:sender_id], community_id: current_community.id)
    if sender.present?
      conversation = Conversation.find_by(id: params[:id])
      if conversation.present?
        if conversation.participant?(sender)
          message = conversation.messages.new(content: params[:content], sender_id: sender.id)
          if message.save
            Delayed::Job.enqueue(MessageSentJob.new(message.id, current_community.id))
            #message = MessageEntity[message].merge({mood: :neutral}).merge(sender: person_entity_with_display_name(PersonEntity.person(sender, current_community.id)))            
            #render json: {conversation_id: conversation.id, message: message}, status: 200
            get_messages_response(sender, conversation.tx.id)
          else
            render json: {error: message.errors.full_messages.to_sentence}, status: 404
          end
        else
          render json: {error: t("layouts.notifications.you_are_not_authorized_to_do_this")}, status: 404
        end
      else
        render json: {error: "Conversation does not exist!"}, status: 404
      end
    else
      render json: {error: "Sender not found."}, status: 404
    end
  end

private
  def get_messages_response(sender, tx_id)
    m_participant =
      Maybe(
        MarketplaceService::Transaction::Query.transaction_with_conversation(
        transaction_id: tx_id,
        person_id: sender.id,
        community_id: current_community.id))
      .map { |tx_with_conv| [tx_with_conv, :participant] }

    m_admin =
      Maybe(sender.has_admin_rights?(current_community))
      .select { |can_show| can_show }
      .map {
        MarketplaceService::Transaction::Query.transaction_with_conversation(
          transaction_id: tx_id,
          community_id: current_community.id)
      }
      .map { |tx_with_conv| [tx_with_conv, :admin] } 
    transaction_conversation, role = m_participant.or_else { m_admin.or_else([]) }             
    tx = TransactionService::Transaction.get(community_id: current_community.id, transaction_id: tx_id)
         .maybe()
         .or_else(nil)  
    tx_model = Transaction.where(id: tx[:id]).first
    conversation = transaction_conversation[:conversation]
    listing = Listing.where(id: tx[:listing_id]).first
    messages_and_actions = TransactionViewUtils.merge_messages_and_transitions(
      TransactionViewUtils.conversation_messages(conversation[:messages], current_community.name_display_type),
      TransactionViewUtils.transition_messages(transaction_conversation, conversation, current_community.name_display_type))      
    is_author =
      if role == :admin
        true
      else
        listing.author_id == sender.id
      end
    messages = messages_and_actions.reverse.map{|message| message.merge(last_activity: ApplicationController.helpers.time_ago_in_words(message[:created_at]) + " ago")}              
    render json: {
      conversation_id: conversation[:id],
      messages: messages
    }, status: 200
  end   
end
