class Api::V1::TestimonialsController < Api::V1::BaseController
  swagger_controller :Testimonials, 'Testimonials'

  before_action :fetch_feedback_author
  before_action :ensure_authorized_to_give_feedback 
  before_action :ensure_feedback_not_given

  swagger_api :create do
    summary "Create Testimonials"
    notes "This end point is used to give feedback on listing's transaction"
    param :path, "id", :integer, :required, "Transaction id"
    param :form, "text", :string, :optional, "Content of Testimonial"
    param :form, "grade", :boolean, :required, "Grade of feedback {positive => true, negative => false}"
    param :form, "feedback_author_id", :string, :required, "Username of feedback author"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end 

   swagger_api :skip do
    summary "skip Testimonials"
    notes "This end point is used to skip feedback on listing's transaction"
    param :path, "id", :integer, :required, "Transaction id"
    param :form, "feedback_author_id", :string, :required, "username"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end 


  def create
    params[:grade] = params[:grade] == "true" ? "1" : "0"
    @testimonial = @transaction.testimonials.build(text: params[:text], grade: params[:grade],
                                                   receiver_id: @transaction.other_party(@feedback_author).id,
                                                   author_id: @feedback_author.id
                                                  )

    if @testimonial.save
      Delayed::Job.enqueue(TestimonialGivenJob.new(@testimonial.id, current_community.id))
      #render json: {success: "Feedback_sent_to #{PersonViewUtils.person_display_name_for_type(@transaction.other_party(@feedback_author), "first_name_only")}"}, status: 200
      get_transaction_response(@feedback_author,  @transaction.id)
    else
      render json: {error: "Something went wrong, please try later!"}, status: 404
    end
  end

  def skip
    is_author =  @transaction.author ==  @feedback_author
    if is_author
      @transaction.update_attributes(author_skipped_feedback: true)
    else
      @transaction.update_attributes(starter_skipped_feedback: true)
    end
    #render json: {success: "Skipped"}, status: 200
    get_transaction_response(@feedback_author,  @transaction.id)
  end

private

  def fetch_feedback_author
    @feedback_author = Person.find_by(username: params[:feedback_author_id])
    unless @feedback_author.present?
      render joins: {error: "Feedback author not exist."}, status: 404
    end
  end

  def ensure_authorized_to_give_feedback
    # Rails was giving some read-only records. That's why we have to do some manual queries here and use INCLUDES,
    # not joins.
    # TODO Move this to service
    @transaction = Transaction
      .includes(:listing)
      .where("starter_id = ? OR listings.author_id = ?", @feedback_author.id, @feedback_author.id)
      .where({
        community_id: current_community.id,
        id: params[:id]
      })
      .references(:listing)
      .first

    if @transaction.nil?
      render json: {error: "You are not allowed to give feedback on this transaction!"}, status: 404 
    end
  end

  def ensure_feedback_not_given
    transaction_entity = MarketplaceService::Transaction::Entity.transaction(@transaction)
    waiting = MarketplaceService::Transaction::Entity.waiting_testimonial_from?(transaction_entity, @feedback_author.id)

    unless waiting
      render json: {error: "You have already given feedback about this event!"}, status: 404
    end
  end

  def get_transaction_response(person, tx_id)
    m_participant =
      Maybe(
        MarketplaceService::Transaction::Query.transaction_with_conversation(
        transaction_id: tx_id,
        person_id: person.id,
        community_id: current_community.id))
      .map { |tx_with_conv| [tx_with_conv, :participant] }

    m_admin =
      Maybe(person.has_admin_rights?(current_community))
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

