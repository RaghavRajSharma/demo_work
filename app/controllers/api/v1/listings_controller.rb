class Api::V1::ListingsController < Api::V1::BaseController
  swagger_controller :listings, 'Listings'
  before_action :is_authorized_to_post, only: [:create, :create_listing_image, :update, :edit_listing]
  before_action :set_facebook_service, only: [:index]

  swagger_api :index do
    summary "Fetches all listings"
    notes "This lists all the open listings"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :per_page, :integer, :optional, "Per page"
    param :query, :username, :string, :optional, "Username of current_user"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :open do
    summary "Update listing open"
    notes "this updates listing open"
    param :path, :id, :string, :required, "Listing Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  
  swagger_api :close do
    summary "Update listing close"
    notes "this updates listing close"
    param :path, :id, :string, :required, "Listing Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single listing list"
    notes "this results listing details"
    param :path, :id, :string, :required, "Listing Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :search do
    summary "Search listing"
    notes "This search the listings"
    param :query, :category_id, :integer, :optional, "Category Id"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :custom_field, :array, :optional, "Custom fields, [{id: 4, value: [2], type: :selection_group, operator: :or}, {id: 5, value: [2,6], type: :selection_group, operator: :or}]"
    param :query, :keyword, :string, :optional, "Search keyword"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :create do
    summary "Create listing"
    notes "This create the listings"
    param :query, :api_token, :string, :required, "Api token"
    param :form, "listing[title]", :string, :required, "Listing title"
    param :form, "listing[price]", :string, :required, "Price($)"
    param :form, "listing[delivery_methods]", :array, :required, "Delivery method, atleast one from ['shipping', 'pickup']"
    param :form, "listing[length]", :float, :optional, "Length(inch), required if delivery method shipping"
    param :form, "listing[width]", :float, :optional, "Width(inch), required if delivery method shipping"
    param :form, "listing[height]", :float, :optional, "Height(inch), required if delivery method shipping"
    param :form, "listing[weight]", :float, :optional, "Weight(lb), required if delivery method shipping"
    param :form, "listing[description]", :string, :optional, "Description"
    param :form, "listing[origin_loc_attributes][address]", :string, :optional, "Listing address"
    param :form, "listing[origin_loc_attributes][google_address]", :string, :optional, "Listing google address, required if address present"
    param :form, "listing[origin_loc_attributes][latitude]", :string, :optional, "Latitude, required if address present"
    param :form, "listing[origin_loc_attributes][longitude]", :string, :optional, "Longitude, required if address present"
    param :form, "listing[category_id]", :integer, :required, "Category or Subcategory ID"
    param :form, "listing[listing_shape_id]", :integer, :required, "Shape ID"
    param :form, "custom_fields", :Hash, :optional, "Hash of Custom fields with custom_field 'ID' and Value. Ex: {1 => Rigging Innovations,
        2 => CPX,
        3 => One Size,
        4 => 4,
        5 => 18,
        8 => 32}"
    param :form, "willing_to_piece", :boolean, :optional, "Willing to piece, default value is true"
    param :form, "parent_id", :string, :optional, "Parent listing id to create child listing"
    param :form, "listing_images", :array, :optional, "Listing Images id's array of hash, Ex: [{id: 11},{id: 12}]"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :create_listing_image do
    summary "Create a new listing image"
    notes "This creates a new listing image and returns the image's id"
    param :query, :api_token, :string, :required, "Api token"
    param :form, :image, :string, :required, "Base64 image string"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :update do
    summary "Update listing"
    notes "This update the listings"
    param :query, :api_token, :string, :required, "Api token"
    param :path, :id, :integer, :required, "Listing id"
    param :form, "listing[title]", :string, :required, "Listing title"
    param :form, "listing[price]", :string, :required, "Price($)"
    param :form, "listing[delivery_methods]", :array, :required, "Delivery method, atleast one from ['shipping', 'pickup']"
    param :form, "listing[length]", :float, :optional, "Length(inch), required if delivery method shipping"
    param :form, "listing[width]", :float, :optional, "Width(inch), required if delivery method shipping"
    param :form, "listing[height]", :float, :optional, "Height(inch), required if delivery method shipping"
    param :form, "listing[weight]", :float, :optional, "Weight(lb), required if delivery method shipping"
    param :form, "listing[description]", :string, :optional, "Description"
    param :form, "listing[origin_loc_attributes][address]", :string, :optional, "Listing address"
    param :form, "listing[origin_loc_attributes][google_address]", :string, :optional, "Listing google address, required if address present"
    param :form, "listing[origin_loc_attributes][latitude]", :string, :optional, "Latitude, required if address present"
    param :form, "listing[origin_loc_attributes][longitude]", :string, :optional, "Longitude, required if address present"
    param :form, "listing[category_id]", :integer, :required, "Category or Subcategory ID"
    param :form, "listing[listing_shape_id]", :integer, :required, "Shape ID"
    param :form, "custom_fields", :Hash, :optional, "Hash of Custom fields with custom_field 'ID' and Value. Ex: {1 => Rigging Innovations,
        2 => CPX,
        3 => One Size,
        4 => 4,
        5 => 18,
        8 => 32}"
    param :form, "willing_to_piece", :boolean, :optional, "Willing to piece, default value is true"
    param :form, "parent_id", :string, :optional, "Parent listing id to create child listing"
    param :form, "listing_images", :array, :optional, "Listing Images id's array of hash, Ex: [{id: 11},{id: 12}]"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :will_or_not_willing_to_piece do
    summary "Update listing for willing_to_piece"
    notes "this updates listing wheather willing_to_piece or not willing_to_piece"
    param :path, :id, :string, :required, "Listing Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :move_to_top do
    summary "Update listing for willing_to_piece"
    notes "this updates listing wheather willing_to_piece or not willing_to_piece"
    param :path, :id, :integer, :required, "Listing Id"
    param :form, :admin_id, :string, :required, "Admin Id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

   swagger_api :follow_unfollow_listing_emails do
    summary "follow/unfollow listing"
    notes "This endpoint is used to follow/unfollow emails notifications about listing's comments"
    param :form, :username, :string, :required, "username"
    param :form, :id, :integer, :required, "Listing Id"
    param :form, :status, :boolean, :required, "Status will be 'true'or 'false'"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :contact_via_listing do
    summary "Create contact via listing contact"
    notes "This endpoint is used to create contact or send message  listing."
    param :form, :content, :string, :required, "Message content"
    param :form, :sender_id, :string, :required, "Username of sender id."
    param :form, :listing_id, :integer, :required, "Listing id"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end    

  swagger_api :listing_follow_status do
    summary "Get listiing's follow status"
    notes "This end point is used to get the status of person's listing follow or unfollow"
    param :path, :id, :integer, :required, "listing_id"
    param :path, :follower_id, :string,:required, "Username of person"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def index
  	listings = ListingsFeedPresenter.new(current_community, current_community.shapes, current_community.transaction_processes, params)
    listings.listings.each do |listing|
      other_user = Person.find(listing[:author][:id])
      if @fb && @current_user != other_user && other_user.authentication_token
        friends_in_common  = @fb.mutual_friends(other_user.authentication_token)
      else
        friends_in_common = []
      end
      listing.merge!(common_friends_count: friends_in_common.size)
    end
    render json: listings, status: 200
  end

  def create
    params[:listing].delete("origin_loc_attributes") if params[:listing][:origin_loc_attributes][:address].blank?
    params[:listing][:delivery_methods] = (params[:listing][:delivery_methods].class.to_s == "String") ? eval(params[:listing][:delivery_methods]) : params[:listing][:delivery_methods]
    params[:custom_fields] = (params[:custom_fields].class.to_s == "String") ? eval(params[:custom_fields]) : params[:custom_fields]
    params[:listing_images] = (params[:listing_images].class.to_s == "String") ? eval(params[:listing_images]) : params[:listing_images] if params[:listing_images].present?
    if params[:listing][:delivery_methods].exclude?("shipping")
      params[:listing][:length] = nil
      params[:listing][:width] = nil
      params[:listing][:height] = nil
      params[:listing][:weight] = nil
    end
    shape = get_shape(Maybe(params)[:listing][:listing_shape_id].to_i.or_else(nil))
    listing_uuid = UUIDUtils.create

    render json: {error: "Listing creation failed: Failed to connect to the booking service. Please try again."}, status: 406  unless create_booking(shape, listing_uuid)
    
    result = ListingFormViewUtils.build_listing_params(shape, listing_uuid, params, current_community)
    
    render json: {error: "Something went wrong"}, status: result.data.join(', ') unless result.success

    listing = Listing.new(result.data)

    parent_listing = Listing.find_by(id: params[:parent_id]) if params[:parent_id].present?
    if parent_listing
      listing.parent_id = parent_listing.id
      listing.willing_to_piece = false if params[:willing_to_piece] == "false"
    end

    ActiveRecord::Base.transaction do
      listing.author = current_api_user
      if listing.save
        listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])
        listing.reorder_listing_images(params, current_api_user.id)
        notify_about_new_listing(listing)
        render json: listing, status: 200
      else
        render json: {error: "Listing could not be saved"}, status: 400
      end
    end
  end

  def open
    listing = current_community.listings.find(params[:id])
    if listing.present?
      if listing.update_attribute(:open, true)
        permitted_params = params.permit!
        render json: listing, status: 200
        #render json: listing, serializer: ListingSerializer, serializer_options: {:params => permitted_params}, status: 200
      else
        render json: {error: listing.errors.full_messages.to_sentence}, status: 400
      end  
    else
      render json: {error: "Listing not found!" }, status: 400
    end 
  end  

  def close
    listing = current_community.listings.find(params[:id])
    if listing.present?
      if listing.update_attribute(:open, false)
        render json: listing, status: 200
      else
        render json: {error: listing.errors.full_messages.to_sentence}, status: 400
      end  
    else
      render json: {error: "Listing not found!" }, status: 400
    end 
  end

  def show
    listing = current_community.listings.find(params[:id])
    if listing.present?
      render json: listing, status: 200
    else
      render json: {error: "Listing not found!" }, status: 400
    end
  end

  swagger_api :search_suggestion do
    summary "Get all suggestion for search"
    notes "This end point is use to get search listing suggestions"
    param :query, :term, :string, :required, "Term for search"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end  

  def search_suggestion
    if params[:term].present?
      listings = Listing.currently_open.where(deleted: false).where("lower(title) LIKE ?", "%#{params[:term].downcase}%") 
      suggestions = listings.map{|l| {id: l.id, text: "#{l.title} in #{l.category.display_name(I18n.locale)}", value: l.title, category: l.category.display_name(I18n.locale), category_id: l.category_id} }
      render json: suggestions, status: 200
    else
      render json: {}, status: 200
    end    
  end

  def search
    includes = [:author, :listing_images].to_set
    page = params[:page] || 1
    custom_field = (params[:custom_field].class.to_s == "String") ? eval(params[:custom_field]) : params[:custom_field]
    m_selected_category = Maybe(current_community.categories.find_by_url_or_id(params[:category_id]))
    categories = m_selected_category.own_and_subcategory_ids.or_nil
    unless params[:keyword].present?
      search = {
        categories: categories,
        keywords: params[:keyword],
        fields: custom_field,
        per_page: 24,
        page: page,
        locale: I18n.locale,
        include_closed: false,
        sort: nil
      }
    else
      listings = Listing.currently_open.where(deleted: false).where("lower(title) LIKE ?", "%#{params[:keyword].downcase}%")
      search = {
        listing_ids: listings.map(&:id),
        per_page: 24,
        page: page,
        locale: I18n.locale,
        include_closed: false
      }      
    end  
    raise_errors = Rails.env.development?
    search_result =  ListingIndexService::API::Api.listings.search(
      community_id: current_community.id,
      search: search,
      includes: includes,
      engine: FeatureFlagHelper.search_engine,
      raise_errors: raise_errors
      ).and_then { |res|
      Result::Success.new(
        ListingIndexViewUtils.to_struct(
          result: res,
          includes: includes,
          page: page,
          per_page: 24
        )
      )
    }
    search_result.on_success { |listings|
      render json: listings, status: 200
    }.on_error {
      render json: {error: "Bad request, No lisitng found!" }, status: 400
    }
  end

  def create_listing_image
    if params[:image].present?
      image = decode_image(params[:image], nil)
      listing_image = ListingImage.new(image: image, author_id: current_api_user.id)
      if listing_image.save
        File.delete(image)
        image_url = "https://theflyingflea.com#{listing_image.image.url}"
        render json: {listing_image_id: listing_image.id, image_url: image_url}, status: 200
      else
        render json: {error: listing_image.errors.full_messages.to_sentence}, status: 400
      end
    else
      render json: {error: "Please upload image in valid format.(ex- jpeg,png,jpg..)" }, status: 400
    end
  end

  def update
    listing = Listing.find_by!(id: params[:id], community_id: current_community.id)
    if listing.present?
      params[:listing][:delivery_methods] = (params[:listing][:delivery_methods].class.to_s == "String") ? eval(params[:listing][:delivery_methods]) : params[:listing][:delivery_methods]
      params[:custom_fields] = (params[:custom_fields].class.to_s == "String") ? eval(params[:custom_fields]) : params[:custom_fields]
      params[:listing_images] = (params[:listing_images].class.to_s == "String") ? eval(params[:listing_images]) : params[:listing_images] if params[:listing_images].present?      
      if params[:listing][:delivery_methods].first != "shipping"
        params[:listing][:length] = nil
        params[:listing][:width] = nil
        params[:listing][:height] = nil
        params[:listing][:weight] = nil
      end
      if (params[:listing][:origin] && (params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin].blank?))
        params[:listing].delete("origin_loc_attributes")
        if listing.origin_loc
          listing.origin_loc.delete
        end
      end 
      shape = get_shape(params[:listing][:listing_shape_id])
      unless create_booking(shape, listing.uuid_object)
        render json: {error: "Listing creation failed: Failed to connect to the booking service. Please try again."}, status: 406
      end
      result = ListingFormViewUtils.build_listing_params(shape, listing.uuid_object, params, current_community)
      unless result.success
        render json: {error: "Something went wrong, please try later!"}, status: 404
      end
      listing_params = result.data.merge(listing.closed? ? {open: true} : {}) 
      old_availability = listing.availability.to_sym 
      update_successful = listing.update_fields(listing_params)
      listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])
      if update_successful
        #delete and update new listing
        if params[:listing_images].present?
          listing_images_ids = listing.listing_images.pluck(:id)
          listing_images_params_ids = params[:listing_images].collect { |h| h[:id] }.select { |id| id.present? }
          images_to_delete_ids = listing_images_ids - listing_images_params_ids
          new_images_ids = listing_images_params_ids - listing_images_ids
          ListingImage.where(id: images_to_delete_ids).destroy_all if images_to_delete_ids.present?
          ListingImage.where(id: new_images_ids, author_id: current_api_user.id).update_all(listing_id: listing.id) if new_images_ids.present?
        end
        #delete and update new listing
        if listing.location
          location_params = ListingFormViewUtils.permit_location_params(params)
          location_params ||= {}
          listing.location.update_attributes(location_params)
        end
        Delayed::Job.enqueue(ListingUpdatedJob.new(listing.id, current_community.id))
        render json: listing, status: 200
      else
        render json: {error: "Listing could not be saved"}, status: 400
      end                     
    else
      render json: {error: "Listing not found!"}, status: 404
    end  
  end

  def will_or_not_willing_to_piece
    listing = Listing.find_by!(id: params[:id], community_id: current_community.id)
    if listing.present?
      if listing.update_column(:willing_to_piece, !listing.willing_to_piece)
        render json: {"listing" => {id: listing.id, willing_to_piece: listing.willing_to_piece}}, status: 200
      else
        render json: {error: "Something went wrong, please try later!"}, status: 404
      end
    else
      render json: {error: "Listing not found!"}, status: 404
    end  
  end

  def move_to_top
    person = Person.find_by(id: params[:admin_id])
    if person.present?
      if person.is_admin?
        listing = Listing.find_by(id: params[:id])
        if listing.present?
          if listing.update_attribute(:sort_date, Time.now)
            render json: {success: "Listing moved to top of homepage successfully."}, status: 200
          else
            render json: {error: "Something went wrong, please try later!"}, status: 404
          end
        else
          render json: {error: "Listing not found!"}, status: 404
        end
      else
        render json: {error: "Your are not authorized to perform this action."}, status: 404
      end
    else
      render json: {error: "Person not found!"}, status: 404
    end
  end


  def follow_unfollow_listing_emails
    listing = Listing.find_by(id: params[:id])
    person = Person.find_by(username: params[:username])
    if (listing.present? && person.present?) && params[:status].present?
      if params[:status].eql?("true")
        if person.follow(listing)   
          render json: {success: "emails for comments followed successfully."}, status: 200
        else
          render json: {error: "Something went wrong, please try again later."}, status: 404
        end  
      elsif params[:status].eql?("false")
        if person.unfollow(listing) 
         render json: {success: "emails for comments unfollowed successfully."}, status: 200
        else
          render json: {error: "Something went wrong, please try again later."}, status: 404
        end 
      end
    else
      render json: {error: "Invalid parameter!"}, status: 404
    end
  end

 def listing_follow_status
   listing = Listing.find_by(id: params[:id])
   person = Person.find_by(username: params[:follower_id])
   if (listing.present? && person.present?)
     all_followers_ids = listing.followers.pluck(:id)
     if all_followers_ids.include?(person.id)
       render json: {id: person.id, following_status: true}, status: 200
     else
      render json: {id: person.id, following_status: false}, status: 200
     end
   else
    render json: {error: "Person or Listing not found"}, status: 404
   end
 end

  def contact_via_listing
    person  = Person.find_by(Username: params[:sender_id])
    listing =  Listing.find_by(id: params[:listing_id])
    if (person.present? && listing.present?) && params[:content].present?
      contact_form = {content: params[:content], sender_id: person.id, listing_id: listing.id, community_id: current_community.id}
      if contact_form.present?
        transaction_response = TransactionService::Transaction.create(
          {
            transaction: {
              community_id: current_community.id,
              community_uuid: current_community.uuid_object,
              listing_id: listing.id,
              listing_uuid: listing.uuid_object,
              listing_title: listing.title,
              starter_id: person.id,
              starter_uuid: person.uuid_object,
              listing_author_id: listing.author.id,
              listing_author_uuid: listing.author.uuid_object,
              unit_type: listing.unit_type,
              unit_price: listing.price,
              unit_tr_key: listing.unit_tr_key,
              availability: :none, # Always none for free transactions and contacts
              listing_quantity: 1,
              content: params[:content],
              payment_gateway: :none,
              payment_process: :none}
          })

        unless transaction_response[:success]
          render json: {error: "Sending the message failed. Please try again."}, status: 404
        end

        transaction_id = transaction_response[:data][:transaction][:id]
        MarketplaceService::Transaction::Command.transition_to(transaction_id, "free")

        # TODO: remove references to transaction model
        transaction = Transaction.find(transaction_id)
        Delayed::Job.enqueue(MessageSentJob.new(transaction.conversation.messages.last.id, current_community.id))

        render json: {success: "Message sent successfully."} , status: 200
      else
        render json: {error: "Person Email or listing does not exist!"}, status: 404
      end
    else
      render json: {error: "Invalid parameter"}, status: 404
    end
  end

  swagger_api :listing_suggestion do
    summary "Get listiing title suggestions"
    notes "This end point is used to get listing's title suggestions"
    param :query, :term, :string, :required, "Query for listing title suggestion"
    param :query, :category, :integer, :optional, "Category Id, either category id or subcatrory id is must"
    param :query, :subcategory, :integer, :optional, "Subcategory Id, either category id or subcatrory id is must"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def listing_suggestion
    if params[:term].present? && (params[:category].present? || params[:subcategory].present?)
      category = params[:subcategory].present? ? params[:subcategory] : params[:category]
      titles = ListingTitleService.new(category).search_title_options(params[:term])
      if titles.present?
        render json: {titles: titles}, status: 200
      else
        render json: {titles: []}, status: 404
      end  
    else
      render json: {titles: []}, status: 404
    end    
  end  

  swagger_api :get_fields_from_title do
    summary "Get listiing title suggestions"
    notes "This end point is used to get listing's title suggestions"
    param :query, :title, :string, :required, "Selected title from listing suggestions."
    param :query, :category, :integer, :optional, "Category Id, either category id or subcatrory id is must"
    param :query, :subcategory, :integer, :optional, "Subcategory Id, ither category id or subcatrory id is must"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def get_fields_from_title
    if params[:title].present?
      category = params[:subcategory].present? ? params[:subcategory] : params[:category]
      results = ListingTitleService.new(category).get_fields_from_title(params[:title])
      if results.present?
        render json: {results: results}, status: 200
      else
        render json: {results: []}, status: 400
      end
    else
      render json: {results: []}, status: 400
    end
  end  

  swagger_api :get_models_by_manufacturer do
    summary "Get models by manufacturer"
    notes "This end point is used to get get models by manufacturer"
    param :query, :category_id, :integer, :required, "Category id"
    param :query, :manufacturer_name, :string, :required, "manufacturer name"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end 

  def get_models_by_manufacturer
    if params[:category_id].present? && params[:manufacturer_name].present?
      models = Product.models_by_manufacturer_and_category(params[:category_id], params[:manufacturer_name])
      models = models.map{|model| [model,model] } + [['Other', 'Other']]
      render json: {models: models}, status: 200
    else
      render json: {models: []}, status: 400
    end
  end

  swagger_api :get_container_sizes_by_model do
    summary "Get container sizes by model"
    notes "This end point is used to get container sizes by model"
    param :query, :category_id, :integer, :required, "Category id"
    param :query, :manufacturer_name, :string, :required, "manufacturer name"
    param :query, :model_name, :string, :required, "model name"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end  

  def get_container_sizes_by_model
    if params[:category_id].present? && params[:manufacturer_name].present? && params[:model_name].present?
      if params[:model_name] == "Other"
        result = ['Other', 'Other']
        render json: {container_sizes: result}, status: 200
      else 
        category_hash = Product.category_hash(params[:category_id])
        result = category_hash[params[:manufacturer_name]].select{|c| c[:manufacturer] == params[:manufacturer_name] && c[:model] == params[:model_name]}.first
        container_sizes = result[:container_sizes].map{|container| [container, container]}
        if container_sizes.present?
          render json: {container_sizes: container_sizes}, status: 200
        else
          render json: {container_sizes: []}, status: 400 
        end
      end  
    else
      render json: {container_sizes: []}, status: 200
    end
  end

  swagger_api :edit_listing do
    summary "Edit listing"
    notes "This end point is used to edit listing"
    param :path, :id, :integer, :required, "Listing Id"
    param :query, :api_token, :string, :required, "Api token"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end   

  def edit_listing
    listing = Listing.find_by(id: params[:id])
    if listing.present?
      if current_api_user == listing.author || current_api_user.has_admin_rights?(current_community)
        render json: listing, serializer: EditListingSerializer, status: 200
      else
        render json: {error: "You are not authorized to perform this action."},status: 404
      end
    else
      render json: {error: "Listing not found"}, status: 404
    end
  end

  private
    def is_authorized_to_post
      if current_api_user.present?
        if current_community.require_verification_to_post_listings?
          unless current_api_user.has_admin_rights?(current_community) || current_community_membership.can_post_listings?
            render json: {error: "Not authorized to post listing" }, status: 401
          end
        end
      else
        render json: {error: "Need to login first" }, status: 401
      end
    end

    def get_shape(listing_shape_id)
      current_community.shapes.find(listing_shape_id)
    end

    def create_booking(shape, listing_uuid)
      if APP_CONFIG.harmony_api_in_use && shape.present? && shape[:availability] == 'booking'
        create_bookable(current_community.uuid_object, listing_uuid, current_api_user.uuid_object).success
      else
        true
      end
    end

    def notify_about_new_listing(listing)
      Delayed::Job.enqueue(ListingCreatedJob.new(listing.id, current_community.id))
      if current_community.follow_in_use?
        Delayed::Job.enqueue(NotifyFollowersJob.new(listing.id, current_community.id), :run_at => NotifyFollowersJob::DELAY.from_now)
      end
      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(current_community.id).update_from_event(:listing_created, listing)
      if state_changed
        record_event('Listing created successfully', "km_record", {km_event: "Onboarding listing created"}, AnalyticService::EVENT_LISTING_CREATED)
      end
    end

    def set_facebook_service
      @current_user = Person.find_by_username(params[:username])
      if @current_user.authentication_token @current_user.facebook_id
        @fb = FacebookService.new(access_token: @current_user.authentication_token)
      end
    rescue
      @fb = nil
    end   
end