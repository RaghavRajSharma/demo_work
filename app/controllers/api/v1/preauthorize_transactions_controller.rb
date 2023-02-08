require 'shippo'
class Api::V1::PreauthorizeTransactionsController < Api::V1::BaseController
  swagger_controller :preauthorize_transactions, 'Preauthorize Transactions'

  before_action :set_listing_and_buyer
  before_action :ensure_listing_is_open
  before_action :ensure_listing_author_is_not_current_user
  before_action :ensure_authorized_to_reply
  before_action :ensure_can_receive_payment

  ListingQuery = MarketplaceService::Listing::Query

  class ItemTotal
    attr_reader :unit_price, :quantity

    def initialize(unit_price:, quantity:)
      @unit_price = unit_price
      @quantity = quantity
    end

    def total
      unit_price * quantity
    end
  end

  class ShippingTotal
    attr_reader :initial, :additional, :quantity

    def initialize(initial:, additional:, quantity:)
      @initial = initial || 0
      @additional = additional || 0
      @quantity = quantity
    end

    def total
      initial + (additional * (quantity - 1))
    end
  end

  class NoShippingFee
    def total
      0
    end
  end  

  class OrderTotal
    attr_reader :item_total, :shipping_total, :tax

    def initialize(item_total:, shipping_total:, tax:)
      @item_total = item_total
      @shipping_total = shipping_total
      @tax = tax
    end

    def total
      item_total.total + shipping_total.total + @tax
    end
  end

  swagger_api :price_breake_down do
    summary "Price break down api"
    notes "This end point is used to get price break down of a listing."
    param :path,  "id", :integer, :required, "Listing Id"
    param :form, "name", :string, :optional, "First and last names, {field is required for shipping.}"
    param :form, "street1", :string, :optional, "Street address line 1 {field is required for shipping.}"
    param :form, "street2", :string, :optional, "Street address line 2 {field is required for shipping.} "
    param :form, "postal_code", :integer, :optional, "ZIP / Postal code {field is required for shipping.}"
    param :form, "city", :string, :optional, "City {field is required for shipping.}"
    param :form, "country_code", :string, :optional, "Country {field is required for shipping.}"
    param :form, "state_or_province", :string, :optional, "State {field is required for shipping.}"
    param :form, "buyer_id", :string, :required, "Username"
    param :form, "shipping", :boolean, :required, "delivery Type {shipping = true, pickup = false}"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable    
  end    

  def price_breake_down
    is_booking = date_selector?(@listing)
    delivery = params[:shipping] ? "shipping".to_s.to_sym : "pickup".to_s.to_sym
    @shipment = calculate_shipping_amount(@listing, @buyer) if params[:shipping]
    tx_params = {delivery: delivery, start_on: nil, end_on: nil, message: nil, quantity: nil, contract_agreed: true}
    quantity = calculate_quantity(tx_params: tx_params, is_booking: is_booking, unit: @listing.unit_type)
    listing_entity = ListingQuery.listing(@listing.id)
    listing_entity[:shipping_price] =  Money.new(@shipment.rates[1].amount.to_f*100, @current_community.currency)  if @shipment.present?
    item_total = ItemTotal.new(
      unit_price: listing_entity[:price],
      quantity: quantity)
    tax = calculate_tax(@listing, item_total.total.to_f)
    shipping_total = calculate_shipping_from_entity(tx_params: tx_params, listing_entity: listing_entity, quantity: quantity)
    order_total = OrderTotal.new(
      item_total: item_total,
      shipping_total: shipping_total,
      tax: tax

    )    
    price_break_down_locals = TransactionViewUtils.price_break_down_locals(
        booking:  is_booking,
        quantity: quantity,
        start_on: tx_params[:start_on],
        end_on:   tx_params[:end_on],
        duration: quantity,
        listing_price: listing_entity[:price],
        localized_unit_type: translate_unit_from_listing(listing_entity),
        localized_selector_label: translate_selector_label_from_listing(listing_entity),
        subtotal: subtotal_to_show(order_total),
        tax: tax,
        shipping_price: shipping_price_to_show(tx_params[:delivery], shipping_total),
        total: order_total.total,
        unit_type: @listing.unit_type
      )
    price_break_down_locals = price_break_down_locals.merge(shipment: @shipment) if @shipment.present?
    if price_break_down_locals.present?
      render json: {price_break_down_locals: price_break_down_locals}, status: 200
    else
      render json: {error: "Something went wrong please try later."},status: 404
    end
  end

  swagger_api :initiated do
    summary "Initiated transaction"
    notes "This end point is use for start transaction"
    param :path, "id", :integer, :required, "Listing Id."
    param :form, "shipping_address[name]", :string, :optional, "First and last names, {field is required for shipping.}"
    param :form, "shipping_address[street1]", :string, :optional, "Street address line 1 {field is required for shipping.}"
    param :form, "shipping_address[street2]", :string, :optional, "Street address line 2"
    param :form, "shipping_address[postal_code]", :integer, :optional, "ZIP / Postal code {field is required for shipping.}"
    param :form, "shipping_address[city]", :string, :optional, "City {field is required for shipping.}"
    param :form, "shipping_address[country_code]", :string, :optional, "Country {field is required for shipping.}"
    param :form, "shipping_address[state_or_province]", :string, :optional, "State {field is required for shipping.}"
    param :form, "buyer_id", :string, :required, "Username"
    param :form, "payment_type", :string, :required, "Payment Type [stripe or paypal]"
    param :form, "stripe_token", :string, :required, "Stripe Token"
    param :form, "contract_agreed", :boolean, :required, "Contract for the Flying Flea Terms of Use"
    param :form, "shipping", :boolean, :required, "delivery Type {shipping = true, pickup = false}"
    param :form, "rate", :float, :optional, "Selected shipping rate, {required in case of delivery = shipping}"
    param :form, "shipment_rate_id", :string, :optional, "Selected shipping rate id,{required in case of delivery = shipping}"
    param :form, "message", :string, :required, "Transaction message"   
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def initiated
    is_booking = date_selector?(@listing)
    delivery = params[:shipping] ? "shipping".to_s.to_sym : "pickup".to_s.to_sym
    contract_agreed = params[:contract_agreed] == "true" ? true : false
    tx_params = {delivery: delivery, start_on: nil, end_on: nil, message: params[:message], quantity: nil, contract_agreed: contract_agreed}
    quantity = calculate_quantity(tx_params: tx_params, is_booking: is_booking, unit: @listing.unit_type)
    shipping_amount = (tx_params[:delivery] == :shipping && params[:rate].present?) ? Money.new(params[:rate].to_f*100, current_community.currency) : nil
    shipping_total = calculate_shipping_from_model(tx_params: tx_params, listing_model: @listing, quantity: quantity, shipping_amount: shipping_amount)
    if params[:shipment_rate_id].present?
      begin
        shippo_transaction = Shippo::Transaction.create(:rate => params[:shipment_rate_id],
                                                        :label_file_type => "PDF",
                                                        :async => false)
      rescue
        render json: {error: "Something went wrong please try later!"},status: 404
      end  
      if shippo_transaction.status == 'ERROR'
        render json: {error: shippo_transaction.messages.last["text"]}, status: 404
      end
    end
    tx_response = create_preauth_transaction(
      payment_type: params[:payment_type].to_sym,
      community: current_community,
      listing: @listing,
      listing_quantity: quantity,
      user: @buyer,
      shipping_tracking_number: shippo_transaction&.tracking_number,
      content: tx_params[:message],
      force_sync: !request.xhr?,
      delivery_method: tx_params[:delivery],
      shipping_price: shipping_total.total,
      booking_fields: {
        start_on: tx_params[:start_on],
        end_on: tx_params[:end_on]
      })

    handle_tx_response(tx_response, params[:payment_type].to_sym)          
  end

private

  def calculate_shipping_amount(listing, buyer)
    Shippo::API.token = APP_CONFIG.shippo_api_token
    author = listing.author
    address_from = {
      :name => author.full_name,
      :email => author.primary_email.address
    }
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{listing.origin_loc.latitude},#{listing.origin_loc.longitude}"      
    begin
      url = URI.escape(geocoder) 
      resp = RestClient.get(url)
    rescue
      return render json: {error: "Something went wrong,please try later!"},status: 404
    end  
    result = JSON.parse(resp.body)
    if result["status"] == "OK"
      result["results"][0]["address_components"].each do |component|
        if component["types"].include? "postal_code"
          address_from[:zip] = component["long_name"]
        elsif component["types"].include? "country"
          address_from[:country] = component["short_name"]
        elsif component["types"].include? "administrative_area_level_1"
          address_from[:state] = component["short_name"]
        elsif component["types"].include? "locality"
          address_from[:city] = component["long_name"]
        end
      end
      address_from[:street1] = "#{result["results"][0]["address_components"][0]['long_name']}, #{result["results"][0]["address_components"][1]['long_name']}, #{result["results"][0]["address_components"][2]['long_name']}" rescue nil
    end 
    address_from[:phone] = author.phone_number if author.phone_number.present?
    address_to = {
      :name => params[:name],
      :street1 => params[:street1],
      :city => params[:city],
      :state => params[:state_or_province],
      :zip => params[:postal_code],
      :country => params[:country_code],
      :email => buyer.primary_email.address
    } 
    address_to[:phone] = buyer.phone_number if buyer.phone_number.present?

    parcel = {
      :length => listing.length,
      :width => listing.width,
      :height => listing.height,
      :distance_unit => :in,
      :weight => listing.weight,
      :mass_unit => :lb
    }
    begin
      shipment = Shippo::Shipment.create(
        :address_from => address_from,
        :address_to => address_to,
        :parcels => parcel,
        :async => false
      )
    rescue
      return render json: {error: "Something went wrong, please try later!"},status: 404
    end                        
  end

  def calculate_tax(listing, item_total)
    # result = Avalara.geographical_tax(listing.origin_loc.latitude, listing.origin_loc.longitude, item_total.total.to_f)
    Money.new(0, @current_community.currency)
  end

  def handle_tx_response(tx_response, gateway)
    if !tx_response[:success]
      render json: {error: "An error occurred during the payment process. Could not finalize your Stripe payment."}, status: 404
    elsif (tx_response[:data][:gateway_fields][:redirect_url])
      render json: {error: "An error occurred during the payment process. Could not finalize your Stripe payment."}, status: 404
    elsif gateway == :stripe
      render json: Transaction.find_by(id: tx_response[:data][:transaction][:id]),status: 200
    else
      render json: {error: "An error occurred during the payment process. Could not finalize your Stripe payment."}, status: 404
    end
  end  

  def calculate_shipping_from_entity(tx_params:, listing_entity:, quantity:)
    calculate_shipping(
      tx_params: tx_params,
      initial: listing_entity[:shipping_price],
      additional: listing_entity[:shipping_price_additional],
      quantity: quantity)
  end

  def calculate_shipping_from_model(tx_params:, listing_model:, quantity:, shipping_amount:)
    calculate_shipping(
      tx_params: tx_params,
      initial: shipping_amount,
      additional: listing_model.shipping_price_additional,
      quantity: quantity)
  end   

  def calculate_shipping(tx_params:, initial:, additional:, quantity:)
    if tx_params[:delivery] == :shipping
      ShippingTotal.new(
        initial: initial,
        additional: additional,
        quantity: quantity)
    else
      NoShippingFee.new
    end
  end    

  def set_listing_and_buyer
    @listing = Listing.find_by(id: params[:id])
    @buyer = Person.find_by(username: params[:buyer_id])
    if (!@listing.present? && !@buyer.present?)
      render json: {error: "Lisitn or buyer doesn't exist"}, status: 404
    end
  end
 
  def ensure_listing_is_open
    if @listing.closed?
      render json: {error: "You cannot reply to a closed offer"}, status: 404  
    end 
  end

  def ensure_listing_author_is_not_current_user
    if @listing.author == @buyer
      render json: {error: "You cannot buy your own listing."}, error: 404
    end
  end 

  def ensure_authorized_to_reply
    unless @listing.visible_to?(@buyer, current_community)
      render json: {error: "You are not authorized to view this content"}, status: 404
    end
  end

  def ensure_can_receive_payment
    payment_type = MarketplaceService::Community::Query.payment_type(current_community.id) || :none

    ready = TransactionService::Transaction.can_start_transaction(transaction: {
        payment_gateway: payment_type,
        community_id: current_community.id,
        listing_author_id: @listing.author.id
      })

    unless ready[:data][:result]
      render json: {error: "Please contact the author by pressing the 'Contact' button below. They need to update their payment details to receive payments."}, status: 404
    end
  end

  def date_selector?(listing)
    [:day, :night].include?(listing.quantity_selector&.to_sym)
  end 

  def calculate_quantity(tx_params:, is_booking:, unit:)
    if is_booking
      DateUtils.duration(tx_params[:start_on], tx_params[:end_on])
    else
      tx_params[:quantity] || 1
    end
  end

  def translate_unit_from_listing(listing)
    Maybe(listing).select { |l|
      l[:unit_type].present?
    }.map { |l|
      ListingViewUtils.translate_unit(l[:unit_type], l[:unit_tr_key])
    }.or_else(nil)
  end

  def translate_selector_label_from_listing(listing)
    Maybe(listing).select { |l|
      l[:unit_type].present?
    }.map { |l|
      ListingViewUtils.translate_quantity(l[:unit_type], l[:unit_selector_tr_key])
    }.or_else(nil)
  end

  def subtotal_to_show(order_total)
    order_total.item_total.total if show_subtotal?(order_total)
  end

  def shipping_price_to_show(delivery_method, shipping_total)
    shipping_total.total if show_shipping_price?(delivery_method)
  end

  def show_subtotal?(order_total)
    order_total.total != order_total.item_total.unit_price
  end

  def show_shipping_price?(delivery_method)
    delivery_method == :shipping
  end        

  def create_preauth_transaction(opts)
    case opts[:payment_type].to_sym
    when :paypal
      # PayPal doesn't like images with cache buster in the URL
      logo_url = Maybe(opts[:community])
               .wide_logo
               .select { |wl| wl.present? }
               .url(:paypal, timestamp: false)
               .or_else(nil)

      gateway_fields =
        {
          merchant_brand_logo_url: logo_url,
          success_url: success_paypal_service_checkout_orders_url,
          cancel_url: cancel_paypal_service_checkout_orders_url(listing_id: opts[:listing].id)
        }
    when :stripe
      gateway_fields =
        {
          stripe_email: @buyer.primary_email.address,
          stripe_token: params[:stripe_token],
          shipping_address: params[:shipping_address],
          service_name: current_community.name_with_separator(I18n.locale)
        }
    end

    transaction = {
          community_id: opts[:community].id,
          community_uuid: opts[:community].uuid_object,
          listing_id: opts[:listing].id,
          listing_uuid: opts[:listing].uuid_object,
          listing_title: opts[:listing].title,
          shipping_tracking_number: opts[:shipping_tracking_number],
          starter_id: opts[:user].id,
          starter_uuid: opts[:user].uuid_object,
          listing_author_id: opts[:listing].author.id,
          listing_author_uuid: opts[:listing].author.uuid_object,
          tax: calculate_tax(opts[:listing], opts[:listing].price*opts[:listing_quantity]),
          listing_quantity: opts[:listing_quantity],
          unit_type: opts[:listing].unit_type,
          unit_price: opts[:listing].price,
          unit_tr_key: opts[:listing].unit_tr_key,
          unit_selector_tr_key: opts[:listing].unit_selector_tr_key,
          availability: opts[:listing].availability,
          content: opts[:content],
          payment_gateway: opts[:payment_type].to_sym,
          payment_process: :preauthorize,
          booking_fields: opts[:booking_fields],
          delivery_method: opts[:delivery_method]
    }

    if(opts[:delivery_method] == :shipping)
      transaction[:shipping_price] = opts[:shipping_price]
    end
    TransactionService::Transaction.create({
        transaction: transaction,
        gateway_fields: gateway_fields
      },
      force_sync: opts[:payment_type] == :stripe || opts[:force_sync])
  end              
end
