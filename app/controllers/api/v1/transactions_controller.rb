class Api::V1::TransactionsController < Api::V1::BaseController
  swagger_controller :transactions, 'Transactions'

  swagger_api :show do
    summary "Get transaction details"
    notes "This end point can be used to get all received messages price-break-downs as well of a transaction"
    param :path, :id, :integer, :required, "Transaction id"
    param :query, :person_id, :string, :required, "Username of person"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end  

  def show
    person =  Person.find_by(username: params[:person_id])
    if person.present?
      m_participant =
        Maybe(
          MarketplaceService::Transaction::Query.transaction_with_conversation(
          transaction_id: params[:id],
          person_id: person.id,
          community_id: current_community.id))
        .map { |tx_with_conv| [tx_with_conv, :participant] } 

      m_admin =
        Maybe(person.has_admin_rights?(current_community))
        .select { |can_show| can_show }
        .map {
          MarketplaceService::Transaction::Query.transaction_with_conversation(
            transaction_id: params[:id],
            community_id: current_community.id)
        }
        .map { |tx_with_conv| [tx_with_conv, :admin] } 

      transaction_conversation, role = m_participant.or_else { m_admin.or_else([]) }
      tx = TransactionService::Transaction.get(community_id: current_community.id, transaction_id: params[:id])
           .maybe()
           .or_else(nil)
      unless tx.present? && transaction_conversation.present?
        render json: {error: "you are not authorized to view this content"}, status: 404
      end
      tx_model = Transaction.where(id: tx[:id]).first
      conversation = transaction_conversation[:conversation]
      listing = Listing.where(id: tx[:listing_id]).first
      messages_and_actions = TransactionViewUtils.merge_messages_and_transitions(
        TransactionViewUtils.conversation_messages(conversation[:messages], current_community.name_display_type),
        TransactionViewUtils.transition_messages(transaction_conversation, conversation, current_community.name_display_type))      
      MarketplaceService::Transaction::Command.mark_as_seen_by_current(params[:id], person.id)
      is_author =
        if role == :admin
          true
        else
          listing.author_id == person.id
        end
        messages = messages_and_actions.reverse.map{|message| message.merge(last_activity: ApplicationController.helpers.time_ago_in_words(message[:created_at]) + " ago")}
        render json: {
          conversation_id: conversation[:id],
          messages: messages, 
          transaction: {id: tx[:id], current_state: tx[:current_state], delivery_method: tx_model.delivery_method},
          feedback_skipped: tx_model.feedback_skipped_by?(person),
          feedback_given_by_current_user: tx_model.has_feedback_from?(person),
          shipping_address: tx[:shipping_address],
          listing: {id: tx[:listing_id], title: tx[:listing_title]},
          conversation_other_party: person_entity_with_url(other_party(conversation, person)), 
          is_author: is_author, 
          role: role, 
          price_break_down: price_break_down_locals(tx)
        }, status: 200     
    else 
      render json: {error: "Person not found."}, status: 404
    end  
  end

  private
    def person_entity_with_url(person_entity)
      person_entity.merge({
        url: person_path(username: person_entity[:username]),
        display_name: PersonViewUtils.person_entity_display_name(person_entity, current_community.name_display_type)})
    end


    def other_party(conversation, person)
      if person.id == conversation[:other_person][:id]
        conversation[:starter_person]
      else
        conversation[:other_person]
      end
    end    

    def price_break_down_locals(tx)
      if tx[:payment_process] == :none && tx[:listing_price].cents == 0
          nil
      else
        localized_unit_type = tx[:unit_type].present? ? ListingViewUtils.translate_unit(tx[:unit_type], tx[:unit_tr_key]) : nil
        localized_selector_label = tx[:unit_type].present? ? ListingViewUtils.translate_quantity(tx[:unit_type], tx[:unit_selector_tr_key]) : nil
        booking = !!tx[:booking]
        quantity = tx[:listing_quantity]
        show_subtotal = !!tx[:booking] || quantity.present? && quantity >= 1 || tx[:shipping_price].present?
        total_label = (tx[:payment_process] != :preauthorize) ? "Price" : "Total"

        TransactionViewUtils.price_break_down_locals({
          listing_price: tx[:listing_price],
          localized_unit_type: localized_unit_type,
          localized_selector_label: localized_selector_label,
          booking: booking,
          start_on: booking ? tx[:booking][:start_on] : nil,
          end_on: booking ? tx[:booking][:end_on] : nil,
          duration: booking ? tx[:booking][:duration] : nil,
          quantity: quantity,
          subtotal: show_subtotal ? tx[:listing_price] * quantity : nil,
          total: Maybe(tx[:payment_total]).or_else(tx[:checkout_total]),
          seller_gets: Maybe(tx[:payment_total]).or_else(tx[:checkout_total]) - tx[:commission_total],
          fee: tx[:commission_total],
          tax: tx[:tax],
          shipping_price: tx[:shipping_price],
          total_label: total_label,
          unit_type: tx[:unit_type]
        })
      end
    end      
end
