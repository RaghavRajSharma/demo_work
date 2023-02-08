class Api::V1::AcceptPreauthorizedConversationsController < Api::V1::BaseController
  swagger_controller :accept_preauthorized_conversations, 'accept_preauthorized_conversations'
  before_action :fetch_conversation
  before_action :fetch_listing
  before_action :fetch_listing_author
  before_action :ensure_is_author  

  swagger_api :accepted_or_rejected do
    summary "Accept or Reject Transaction"
    notes "This end point is use to accept or reject preauthorized transaction by listing author"
    param :path, "id", :integer, :required, "Transaction Id."
    param :query, "author_id", :string, :required, "Username of author."
    param :form, "content", :string, :optional, "Aceept/Reject message content."
    param :form, "status", :string, :required, "status value {accept: paid, rejected: rejected}"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def accepted_or_rejected
    tx_id = params[:id]
    message = params[:content]
    status = params[:status].to_sym
    sender_id =  @listing_author.id
    tx = TransactionService::API::Api.transactions.query(tx_id)

    if tx[:current_state] != :preauthorized
      render json: {error: "The transaction can not be accept!"},status: 404
    end

    res = accept_or_reject_tx(current_community.id, tx_id, status, message, sender_id)

    if res[:success]
      status == :paid ? "PreauthorizedTransactionAccepted" : "PreauthorizedTransactionRejected"
      #render json: @listing_conversation , status: 200
      get_transaction_response(@listing_author, tx_id)
    else
      render json: {error: "something went wrong please try later!"}, status: 404
    end
  end      

private

  def accept_or_reject_tx(community_id, tx_id, status, message, sender_id)
    if (status == :paid)
      accept_tx(community_id, tx_id, message, sender_id)
    elsif (status == :rejected)
      reject_tx(community_id, tx_id, message, sender_id)
    else
      {flow: :unknown, success: false}
    end
  end

  def accept_tx(community_id, tx_id, message, sender_id)
    TransactionService::Transaction.complete_preauthorization(community_id: community_id,
                                                              transaction_id: tx_id,
                                                              message: message,
                                                              sender_id: sender_id)
      .maybe()
      .map { |_| {flow: :accept, success: true}}
      .or_else({flow: :accept, success: false})
  end

  def reject_tx(community_id, tx_id, message, sender_id)
    TransactionService::Transaction.reject(community_id: community_id,
                                           transaction_id: tx_id,
                                           message: message,
                                           sender_id: sender_id)
      .maybe()
      .map { |_| {flow: :reject, success: true}}
      .or_else({flow: :reject, success: false})
  end  

  def fetch_conversation
    @listing_conversation = current_community.transactions.find_by(id: params[:id])
    if !@listing_conversation.present?
      render json: {error: "Listing conversation doesn't exist"},status: 404
    end
  end

  def fetch_listing
    @listing = @listing_conversation.listing
    if !@listing.present?
      render json: {error: "Listing doesn't exist."},status: 404
    end
  end

  def fetch_listing_author
    @listing_author = Person.find_by(username: params[:author_id])
    if !@listing_author.present?
      render json: {error: "Author doesn't exist."},status: 404
    end
  end  

  def ensure_is_author
    unless @listing.author == @listing_author 
      render json: {error: "Only listing author can perform the requested action"} , status: 404
    end
  end

  def get_transaction_response(author, tx_id)
    m_participant =
      Maybe(
        MarketplaceService::Transaction::Query.transaction_with_conversation(
        transaction_id: tx_id,
        person_id: author.id,
        community_id: current_community.id))
      .map { |tx_with_conv| [tx_with_conv, :participant] }

    m_admin =
      Maybe(author.has_admin_rights?(current_community))
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
        listing.author_id == author.id
      end
    messages = messages_and_actions.reverse.map{|message| message.merge(last_activity: ApplicationController.helpers.time_ago_in_words(message[:created_at]) + " ago")}              
    render json: {
      conversation_id: conversation[:id],
      messages: messages, 
      transaction: {id: tx[:id], current_state: tx[:current_state], delivery_method: tx_model.delivery_method},
      feedback_skipped: tx_model.feedback_skipped_by?(author),
      feedback_given_by_current_user: tx_model.has_feedback_from?(author),
      shipping_address: tx[:shipping_address],
      listing: {id: tx[:listing_id], title: tx[:listing_title]},
      conversation_other_party: person_entity_with_url(other_party(conversation, author)), 
      is_author: is_author, 
      role: role, 
      price_break_down: price_break_down_locals(tx)
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
