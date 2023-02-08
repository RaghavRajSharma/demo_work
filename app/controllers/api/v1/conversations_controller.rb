class Api::V1::ConversationsController < Api::V1::BaseController
  swagger_controller :conversations, 'Conversations'

  swagger_api :show do
    summary "Get all received messages"
    notes "This end point can be used to get all received messages of a conversation/Direct conversations"
    param :path, :id, :integer, :required, "Id of conversation"
    param :query, :person_id, :string, :required, "Username of person"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def show
    person = Person.find_by!(username: params[:person_id])
    if person.present?
      conversation = Conversation.find_by(id: params[:id])
      if conversation.present?
      conversation = MarketplaceService::Conversation::Query.conversation_for_person(
        conversation.id,
        person.id,
        current_community.id)  
        if conversation.blank?
          render json: {error: "you are not authorized to view this content"}, status: 404
        else
          MarketplaceService::Conversation::Command.mark_as_read(conversation[:id], person.id)
          messages = TransactionViewUtils.conversation_messages(conversation[:messages], current_community.name_display_type)
          messages = messages.map{ |message| message.merge(last_activity: ApplicationController.helpers.time_ago_in_words(message[:created_at]) + " ago")}
          render json: {messages: messages}, status: 200
        end      
      else
        render json: {error: "Conversation does not exist!"}, status: 404
      end
    else
      render json: {error: "Person not found."}, status: 404
    end
  end
end
