class Api::V1::ConfirmConversationsController < Api::V1::BaseController
  swagger_controller :confirm_conversations, 'Confirm Conversations'

  before_action :fetch_conversation
  before_action :fetch_listing
  before_action :fetch_renter
  before_action :ensure_is_starter  

  swagger_api :confirmation do
    summary "Mark as complete or Dispute"
    notes "This end point is used for mark as complete or dispute the transaction."
    param :path, "id", :integer, :required, "Transaction id"
    param :form, "confirmed", :boolean, :required, "Status of Transaction {confirmed =>  true, dispute => false}"
    param :form, "give_feedback", :boolean, :required, "Give feedback or skip feedback {give_feedback => true, skip_feedback => false}"
    param :form, "renter_id", :string, :required, "Username of renter"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end   

  # Handles confirm and cancel forms
  def confirmation
    status = params[:confirmed] == "true" ? "confirmed".to_sym : "canceled".to_sym

    if !MarketplaceService::Transaction::Query.can_transition_to?(@listing_transaction.id, status)
      render json: {error: "Something went wrong, please try later!"}, status: 404
    else
      msg = nil
      transaction = complete_or_cancel_tx(current_community.id, @listing_transaction.id, status, msg, @renter.id)

      feedback_given = params[:give_feedback] == "true" ? true : false

      confirmation = ConfirmConversation.new(@listing_transaction, @renter, current_community)
      confirmation.update_participation(feedback_given)
      @listing_transaction.listing && @listing_transaction.listing.mark_closed

      #render json: @listing_transaction , status: 200
      get_transaction_response(@renter,  @listing_transaction.id, feedback_given)
    end     
  end

private
  def complete_or_cancel_tx(community_id, tx_id, status, msg, sender_id)
    if status == :confirmed
      TransactionService::Transaction.complete(community_id: community_id, transaction_id: tx_id, message: msg, sender_id: sender_id)
    else
      (tx = Transaction.find(tx_id)) && (listing = tx.listing) && listing.unmark_sold
      TransactionService::Transaction.cancel(community_id: community_id, transaction_id: tx_id, message: msg, sender_id: sender_id)
    end
  end

  def fetch_renter
    @renter = Person.find_by(username: params[:renter_id])
    unless @renter.present?
      render json: {error: "Renter doesn't exist!"},status: 404  
    end
  end

  def fetch_conversation
    @listing_transaction = current_community.transactions.find_by(id: params[:id])
    unless @listing_transaction
      render json: {error: "Transaction doesn't exist!"}, status: 404  
    end
  end

  def fetch_listing
    @listing = @listing_transaction.listing
    unless @listing.present?
      render json: {error: "There is no listing associated with the transaction!"}, status: 404
    end
  end

  def ensure_is_starter
    unless @listing_transaction.starter == @renter
      render json: {error: "Only listing starter can perform the requested action!"}, status: 404
    end
  end

  def get_transaction_response(renter, tx_id, feedback_given)
    m_participant =
      Maybe(
        MarketplaceService::Transaction::Query.transaction_with_conversation(
        transaction_id: tx_id,
        person_id: renter.id,
        community_id: current_community.id))
      .map { |tx_with_conv| [tx_with_conv, :participant] }

    m_admin =
      Maybe(renter.has_admin_rights?(current_community))
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
        listing.author_id == renter.id
      end
    messages = messages_and_actions.reverse.map{|message| message.merge(last_activity: ApplicationController.helpers.time_ago_in_words(message[:created_at]) + " ago")}              
    render json: {
      conversation_id: conversation[:id],
      messages: messages, 
      transaction: {id: tx[:id], current_state: tx[:current_state], delivery_method: tx_model.delivery_method},
      feedback_skipped: tx_model.feedback_skipped_by?(renter),
      feedback_given_by_current_user: tx_model.has_feedback_from?(renter),
      shipping_address: tx[:shipping_address],
      listing: {id: tx[:listing_id], title: tx[:listing_title]},
      conversation_other_party: person_entity_with_url(other_party(conversation, renter)), 
      is_author: is_author, 
      role: role, 
      price_break_down: price_break_down_locals(tx),
      feedback_given: feedback_given
    }, status: 200
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

  def other_party(conversation, person)
    if person.id == conversation[:other_person][:id]
      conversation[:starter_person]
    else
      conversation[:other_person]
    end
  end 

  def person_entity_with_url(person_entity)
    person_entity.merge({
      url: person_path(username: person_entity[:username]),
      display_name: PersonViewUtils.person_entity_display_name(person_entity, current_community.name_display_type)})
  end             
end
