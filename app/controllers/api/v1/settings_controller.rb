class Api::V1::SettingsController < Api::V1::BaseController
  swagger_controller :settings, 'Profile Settings'
  before_action :ensure_payments_enabled, only: [:create_payment_info, :update_payment_info, :get_payment_info]
  before_action :load_stripe_account, only: [:create_payment_info, :update_payment_info, :get_payment_info]

  swagger_api :profile_info do
    summary "Update Person Profile Information."
    notes "Allow user to display his details and profile"
    param :path, :id, :string, :optional, "Username"
    param :form, :given_name, :string, :optional, "First Name"
    param :form, :family_name, :string, :optional, "Last Name"
    param :form, :display_name, :string, :optional, "Display Name"
    param :form, :jump_number, :string, :optional, "Jump #" 
    param :form, :membership_association, :string, :optional, "Association"
    param :form, :membership_number, :string, :optional, "Membership #"
    param :form, :license_type, :string, :optional, "License Type"
    param :form, :license_number, :string, :optional, "License Number"
    param :query, :rating_ids, :array, :optional, "Array of group Rating(s) example: ['18','19','20']"
    param :form, :profession, :string, :optional, "Profession"
    param :form, :favorite_discipline_id, :integer, :optional, "Favorite Discipline"
    param :query, :discipline_ids, :array, :optional, "Array of group Other Disciplines(s) example: ['25','26','27']"
    param :form, :jumping_since, :integer, :optional, "Jumpin' since"
    param :form, :home_dropzone_name, :string, :optional, "Home Drop Zone"
    param :query, :dropzone_ids, :array, :optional, "Array of group Other Drop Zone(s) example: ['16','17']"
    param :form, :address, :string, :optional, "Location's address"
    param :form, :google_address, :string, :optional, "Location's google address"
    param :form, :latitude, :float, :optional, "Latitude of location" 
    param :form, :longitude, :float, :optional, "Longitude of location"
    param :form, :phone_number, :string, :optional, "Phone number"
    param :form, :description, :text, :optional, "About you"
    param :form, :image, :string, :optional, "Profile picture"
    response :unauthorized
    response :not_acceptable
  end  

  swagger_api :update_email do
    summary "Update Person new email addresses"
    notes "Allow user to  update new email addresses."
    param :path, :id, :string, :required, "Username"
    param :form, :email, :string, :required, "Email"
    param :query, :receive_notification, :boolean, :optional, "Receive notifications"
    param :query, :send_notifications, :array, :optional, "Id of emails for which email notification will be enabled." 
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update_password do
    summary "Update Person password"
    notes "Allow user to  update new password addresses."
    param :path, :id, :string, :required, "Username"
    param :form, :password, :string, :optional, "New Password"
    param :form, :password2, :string, :optional, "Confirm new password"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :destroy_person do
    summary "Delete Account"
    notes "Allow user to Permanently delete account."
    param :path, :id, :string, :optional, "Username"
    response :unauthorized
    response :not_acceptable
  end    

  swagger_api :notifications do
    summary "Update Person Profile Notifications"
    notes "Allow user to updtae notification features"
    param :path, :id, :string, :required, "Username"
    param :form, :min_days_between_community_updates, :integer, :optional, "Newsletters(eg- 1=> daily, 7=> weekly, 100000=> Don't send me newsletters)"
    param :form, :email_from_admins, :boolean, :optional, "Emails from administrators(eg- true = yes, false = no)"
    param :form, :email_about_new_messages, :boolean, :optional, "Email notification when someone sends me a message(eg - true: yes, false: no)"
    param :form, :email_about_new_comments_to_own_listing, :boolean, :optional, "Email notification when someone comments on my offer or request(eg - true: yes, false: no)"
    param :form, :email_when_conversation_accepted, :boolean, :optional, "Email notification when someone accepts my offer or request(eg - true: yes, false: no)" 
    param :form, :email_when_conversation_rejected, :boolean, :optional, "Email notification when someone rejects my offer or request(eg - true: yes, false: no)" 
    param :form, :email_about_new_received_testimonials, :boolean, :optional, "Email notification when someone gives me feedback(eg - true: yes, false: no)" 
    param :form, :email_about_confirm_reminders, :boolean, :optional, "Email notification when I have forgotten to confirm an order as completed(eg - true: yes, false: no)" 
    param :form, :email_about_testimonial_reminders, :boolean, :optional, "Email notification when I have forgotten to give feedback on an event(eg - true: yes, false: no)" 
    param :form, :email_about_completed_transactions, :boolean, :optional, "Email notification when someone marks my order as completed (eg - true: yes, false: no)"
    param :form, :email_about_new_payments, :boolean, :optional, "Email notification when I receive a new payment (eg - true: yes, false: no)"
    param :form, :email_about_new_listings_by_followed_people, :boolean, :optional, "Email notification when someone I follow posts a new listing (eg - true: yes, false: no)"
    param :form, :empty_notification, :integer, :optional, "Empty_notification as hidden field(eg - 0,1)"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :get_profile_info do
    summary "Get profile info"
    notes "Get all profile info"
    param :query, :id, :string, :required, "Username"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :get_account do
    summary "Get account info"
    notes "Get username and emails info"
    param :query, :id, :string, :required, "Username"
    response :unauthorized
    response :not_acceptable
  end   

   swagger_api :delete_account_email do
    summary "delete account emails"
    notes "to delete the emails"
    param :form, :username, :string, :required, "Username"
    param :form, :id, :integer,:required, "email_id"
    response :unauthorized
    response :not_acceptable
  end           

  swagger_api :get_notifications do
    summary "Get profile settings notifications field values"
    notes "This end point is used to get profile settings notifications field values"
    param :query, :id, :string, :required, "Username"
    response :unauthorized
    response :not_acceptable
  end 

  def profile_info
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      if profile_inof_params && profile_inof_params[:location] && (profile_inof_params[:location][:address].blank?)
        profile_inof_params.delete("location")
        if person.location
          person.location.destroy
        end
      end
      
      profile_inof_params.merge!(dropzone_ids: []) unless profile_inof_params[:dropzone_ids]
      #Maybe(profile_inof_params)[:location].each { |loc|
        #profile_inof_params[:location] = loc.merge(location_type: :person)
      #}
      params_to_be_updated = (profile_inof_params[:location] && profile_inof_params[:location][:address].blank?) ? profile_inof_params.except(:location) : profile_inof_params
      if person.update_attributes(params_to_be_updated)
        if params[:image].present?
          profile_image = decode_image(params[:image], person)
          if person.update_attribute(:image, profile_image)
            File.delete(profile_image)
          end  
        end
        person = person.reload
        render json: person, serializer: ProfileInfoSerializer, status: 200
      else
        render json: {error: "Something went wrong, please try later!"}, status: 400
      end      
    else
      render json: {error: "The Person not found" }, status: 404
    end  
  end

  def update_email
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      if params[:email].present?
        person.set_emails_that_receive_notifications(params[:send_notifications])
        person.emails.build(address: params[:email], community_id: current_community.id, send_notifications:
          params[:receive_notification] == 'true' ? true : false)
        if person.save!
          Email.send_confirmation(person.emails.last, current_community)
          render json: {id: person.id, email: person.emails.last}, status: 200
        else
          render json: {error: "Something went wrong, please try later!"}, status: 400
        end
      else
        render json: {error: "pease enter valid email address." }, status: 404
      end
    else
      render json: {error: "The Person not found" }, status: 404
    end
  end

  def update_password
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      if params[:password].present? && params[:password2]
        if params[:password] == params[:password2]
          params.delete(:id)
          password_params = params.permit(:password, :password2)
          if person.update_attributes(password_params)
            render json: {success: "password updated successfully."}, status: 200
          else
            render json: {error: "Something went wrong, please try later!"},status: 404 
          end
        else
          render json: {error: "password and confirmation password doesn't match!" }, status: 404
        end
      else
        render json: {error: "Passowrd and confirm password can't be blank!" }, status: 404
      end
    else
      render json: {error: "The Person not found" }, status: 404
    end
  end

  def destroy_person
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      has_unfinished = TransactionService::Transaction.has_unfinished_transactions(person.id)
      if has_unfinished
        render json: {error: "You can not delete account, as you have unfinshed transaction left."}, status: 404
      else
        begin
          ActiveRecord::Base.transaction do
            UserService::API::Users.delete_user(person.id)
            MarketplaceService::Listing::Command.delete_listings(person.id)

            PaypalService::API::Api.accounts.delete(community_id: person.community_id, person_id: person.id)
          end
          render json: {success: "Account deleted successfully!"}, status: 200
        rescue => e
          render json: {error: "Accounts can not be delete now, please contact admin!"}, status: 404
        end          
      end
    else
      render json: {error: "The Person not found" }, status: 404
    end
  end

  def notifications
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      if person.update_attributes(notification_params)
        render json: person, serializer: NotificationsSerializer, status: 200
      else
        render json: {error: "Something went wrong please try later!"}, status: 404
      end
    else
      render json: {error: "The Person not found" }, status: 404
    end
  end

  swagger_api :create_payment_info do
    summary "Create payment informations"
    notes "This end point is used to allow user to create payment informations first time."
    param :form, :id, :string, :required, "Username"
    param :form, "stripe_account_form[legal_name]", :string, :required, "Legal Name"
    param :form, "stripe_account_form[birth_date(3i)]", :string, :required, "Birth Date"
    param :form, "stripe_account_form[birth_date(2i)]", :string, :required, "Birth Month"
    param :form, "stripe_account_form[birth_date(1i)]", :string, :required, "Birth Year"
    param :form, "stripe_account_form[address_country]",:string, :required, 'Select A country from these lists ["AU", "AT", "BE", "CA", "DK", "FI", "FR", "DE", "HK", "IE", "IT", "LU", "NL", "NZ", "NO", "PT", "ES", "SE", "CH", "GB", "US"]'
    param :form, "stripe_account_form[address_line1]", :string, :required, "Street address*"
    param :form, "stripe_account_form[address_postal_code]", :string, :required, "Postal code*"
    param :form, "stripe_account_form[address_city]", :string, :required, "City*"
    param :form, "stripe_account_form[address_state]", :string, :optional, "State, required for [AU, CA, IE]"
    param :form, "stripe_bank_form[bank_routing_number]", :string, :optional, "BSB required for [AU, GB, US] "
    param :form, "stripe_bank_form[bank_account_number]", :string, :optional, "Account number required for [AU, AT, BE, CA, DK, FI, FR, DE, HK, IE, IT, LU, NL, NZ, NO, PT, ES, SE, CH, GB, US]"
    param :form, "stripe_bank_form[bank_routing_1]", :string, :optional, "Transit number required for [CA, HK]"
    param :form, "stripe_bank_form[bank_routing_2]", :string, :optional, "Institution number required for  [CA, HK]"
    param :form, "stripe_account_form[personal_id_number]", :string, :optional, "Social Insurance Number (SIN)/Hong Kong Identity Card Number required for [CA, HK, US]"
    response :unauthorized
    response :not_acceptable
  end  

  def create_payment_info
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      @extra_forms = {}
      if params[:stripe_account_form].present?
        stripe_create_account(person)
        if @stripe_error
          render json: {error: @error_msg}, status: 404
        end
      end

      if params[:stripe_bank_form].present?
        stripe_update_bank_account
        # If we can't create both account and link external bank account, ignore this partial record, and not store in our DB
        if @stripe_error && @just_created && @stripe_account[:stripe_seller_id].present?
          stripe_accounts_api.destroy(community_id: current_community.id, person_id: person.id)
          @stripe_account[:stripe_seller_id] = nil
          render json: {error: @error_msg}, status: 404
        else
          payment_info = { available_countries: CountryI18nHelper.translate_list(StripeService::Store::StripeAccount::COUNTRIES),
                           stripe_seller_account: @parsed_seller_account, 
                           stripe_address_form: StripeAddressForm.new(@parsed_seller_account),
                           stripe_bank_form: StripeBankForm.new(@parsed_seller_account),
                           stripe_mode: StripeService::API::Api.wrapper.charges_mode(current_community.id),
                         }
          render json: payment_info, status: 200            
          #render json: {success: "Payment info saved successfuly!"}, status: 200
        end
      end            
    else
      render json: {error: "Person does't find"},status: 404
    end
  end

  swagger_api :update_payment_info do
    summary "Update payment informations"
    notes "This end point is used to allow user to update payment informations"
    param :form, :id, :string, :required, "Username"
    param :form, "stripe_address_form[address_line1]", :string, :required, "Street address*"
    param :form, "stripe_address_form[address_postal_code]", :string, :required, "Postal code*"
    param :form, "stripe_address_form[address_city]", :string, :required, "City*"
    param :form, "stripe_address_form[address_state]", :string, :optional, "State, required for [AU, CA, IE]"
    param :form, "stripe_bank_form[bank_routing_number]", :string, :optional, "BSB required for [AU, GB, US] "
    param :form, "stripe_bank_form[bank_account_number]", :string, :optional, "Account number required for [AU, AT, BE, CA, DK, FI, FR, DE, HK, IE, IT, LU, NL, NZ, NO, PT, ES, SE, CH, GB, US]"
    param :form, "stripe_bank_form[bank_routing_1]", :string, :optional, "Transit number required for [CA, HK]"
    param :form, "stripe_bank_form[bank_routing_2]", :string, :optional, "Institution number required for  [CA, HK]"
    param :form, "stripe_account_form[personal_id_number]", :string, :optional, "Social Insurance Number (SIN)/Hong Kong Identity Card Number required for [CA, HK, US]"
    response :unauthorized
    response :not_acceptable
  end 

  def update_payment_info
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      @extra_forms = {}
      if params[:stripe_bank_form].present?
        stripe_update_bank_account
        # If we can't create both account and link external bank account, ignore this partial record, and not store in our DB
        if @stripe_error && @just_created && @stripe_account[:stripe_seller_id].present?
          stripe_accounts_api.destroy(community_id: current_community.id, person_id: person.id)
          @stripe_account[:stripe_seller_id] = nil
          render json: {error: @error_msg}, status: 404
        end
      end
      if params[:stripe_address_form].present?
        stripe_update_address
        if @stripe_error
          render json: {error: @error_msg}, status: 404
        else
          payment_info = { available_countries: CountryI18nHelper.translate_list(StripeService::Store::StripeAccount::COUNTRIES),
                           stripe_seller_account: @parsed_seller_account, 
                           stripe_address_form: StripeAddressForm.new(@parsed_seller_account),
                           stripe_bank_form: StripeBankForm.new(@parsed_seller_account),
                           stripe_mode: StripeService::API::Api.wrapper.charges_mode(current_community.id),
                         }
          render json: payment_info, status: 200             
          #render json: {success: "Payment info updated successfuly!"},status: 200
        end        
      end                  
    else
      render json: {error: "Person does't find"},status: 404
    end
  end

  swagger_api :get_payment_info do
    summary "Get payment informations"
    notes "This end point is used to get payment informations"
    param :path, :id, :string, :required, "Username of person"
    response :unauthorized
    response :not_acceptable
  end    

  def get_payment_info
    peyment_info = { available_countries: CountryI18nHelper.translate_list(StripeService::Store::StripeAccount::COUNTRIES),
                     stripe_seller_account: @parsed_seller_account, 
                     stripe_address_form: StripeAddressForm.new(@parsed_seller_account),
                     stripe_bank_form: StripeBankForm.new(@parsed_seller_account),
                     stripe_mode: StripeService::API::Api.wrapper.charges_mode(current_community.id),
                   }
    render json: peyment_info, status: 200               
  end   

  def get_profile_info
    person = Person.find_by(username: params[:id])
    if person.present?
      render json: person, serializer: GetProfileInfoSerializer, status: 200
    else
      render json: {error: "Invalid Person."},status: 404
    end
  end

  def get_account
    person = Person.find_by(username: params[:id])
    if person.present?
      render json: person, serializer: GetAccountSerializer, status: 200
    else
      render json: {error: "Invalid Person."},status: 404
    end    
  end

  def delete_account_email
    person = Person.find_by(username: params[:username])
    email_id = params[:id]
    email = Email.find_by_id(email_id)
    if (person.present? && email.present?)
      if !email.nil? then
        list_of_allowed_emails = person.accepted_community.allowed_emails
        can_delete = EmailService.can_delete_email(person.emails, email, list_of_allowed_emails)
        if can_delete[:result] == true then
          # Deleting email
          if email.destroy
            render json: {error: "Email deleted successfuly"},status: 200
          else
            render json: {error: "something went wrong ,please try later"},status: 404
          end  
        else
          render json: {error: "Email can not be delted"},status: 404
            # Can not delete the email for some reason
        end
      else
        render json: {error: "You don't have the email address you're trying to remove"},status: 404
        # User didn't have the email she's trying to delete
       end
    else
      render json: {error: "Person or Email does not exist!"},status: 404
    end
  end

  def get_notifications
    person = Person.find_by(username: params[:id])
    if person.present?
      render json: person, serializer: GetNotificationSerializer, status: 200
    else
      render json: {error: "Invalid Person."},status: 404
    end      
  end  

private
  def profile_inof_params
    rating_ids = []
    discipline_ids = []
    dropzone_ids = []
    pip = params.slice(
         :given_name,
         :family_name,
         :display_name,
         :jump_number,
         :membership_association,
         :membership_number,
         :license_type,
         :license_number,
         :phone_number,
         :description,
         :profession,
         :favorite_discipline_id,
         :home_dropzone_name,
         :jumping_since
       )
    unless params[:rating_ids].blank?
      params[:rating_ids].split(',').each do |rating_id|
        rating_ids << rating_id
      end
    else
      rating_ids << ""
    end

    unless params[:discipline_ids].blank?
      params[:discipline_ids].split(',').each do |discipline_id|
        discipline_ids << discipline_id 
      end
    else
      discipline_ids << ""
    end
    
    unless params[:dropzone_ids].blank?
      params[:dropzone_ids].split(',').each do |dropzone_id|
        dropzone_ids << dropzone_id
      end
    end
    pip[:rating_ids]  = rating_ids
    pip[:discipline_ids] = discipline_ids
    pip[:dropzone_ids] = dropzone_ids
    pip[:street_address] = params[:address]
    pip[:location] = {"address" => params[:address], "google_address" => params[:google_address], "latitude" => params[:latitude], "longitude" => params[:longitude], "location_type" => :person}
    return pip.permit!
  end

  def notification_params
    params.delete(:id)
    np = params.slice(:min_days_between_community_updates)
    np[:preferences] = {"email_from_admins" => params[:email_from_admins],
                        "email_about_new_messages" => params[:email_about_new_messages], 
                        "email_about_new_comments_to_own_listing" => params[:email_about_new_comments_to_own_listing],
                        "email_when_conversation_accepted" => params[:email_when_conversation_accepted],
                        "email_when_conversation_rejected" => params[:email_when_conversation_rejected],
                        "email_about_new_received_testimonials" => params[:email_about_new_received_testimonials],
                        "email_about_confirm_reminders" => params[:email_about_confirm_reminders], 
                        "email_about_completed_transactions" => params[:email_about_completed_transactions], 
                        "email_about_new_payments" => params[:email_about_new_payments],
                        "email_about_new_listings_by_followed_people" => params[:email_about_new_listings_by_followed_people]
                       }
    return np.permit!                    
  end

  def ensure_payments_enabled
    @paypal_enabled = PaypalHelper.community_ready_for_payments?(current_community.id)
    @stripe_enabled = StripeHelper.community_ready_for_payments?(current_community.id)
    unless @paypal_enabled || @stripe_enabled
      render json: {error: "In order to receive payments is not possible since payments have not been set up. Please contact admin for details."}
    end
  end

  def load_stripe_account
    @stripe_account = stripe_accounts_api.get(community_id: current_community.id, person_id: Person.find_by_username(params[:id])).data || {}
    if @stripe_account[:stripe_seller_id].present?
      @api_seller_account = stripe_api.get_seller_account(community: @current_community.id, account_id: @stripe_account[:stripe_seller_id])
      @parsed_seller_account = parse_stripe_seller_account(@api_seller_account)
    else
      @parsed_seller_account = {}
    end
  end

  StripeAccountForm = FormUtils.define_form("StripeAccountForm",
        :legal_name,
        :address_country,
        :address_city,
        :address_line1,
        :address_postal_code,
        :address_state,
        :birth_date,
        :personal_id_number
        ).with_validations do
    validates_inclusion_of :address_country, in: StripeService::Store::StripeAccount::COUNTRIES

    validates_presence_of :legal_name
    validates_presence_of :birth_date

    validates_presence_of :address_country, :address_city, :address_line1
    validates_presence_of :address_postal_code, unless: proc { address_country == 'IE'  }
    validates_presence_of :address_state, if: proc { ['IE', 'CA', 'US', 'AU'].include? address_country }
    validates_presence_of :personal_id_number, if: proc { address_country == 'CA' }
  end  

  def stripe_create_account(person)
    if @stripe_account[:stripe_seller_id].present?
      render json: {error: "Payment info alredy exist."}, status: 404
    else
      stripe_account_form = parse_create_params(params[:stripe_account_form])
      @extra_forms[:stripe_account_form] = stripe_account_form
      if stripe_account_form.valid?
        account_attrs = stripe_account_form.to_hash
        first_name, last_name = account_attrs.delete(:legal_name).to_s.split(/\s+/, 2)
        account_attrs[:first_name] = first_name
        account_attrs[:last_name] = last_name
        account_attrs[:tos_ip] = request.remote_ip
        account_attrs[:tos_date] = Time.zone.now
        account_attrs[:email] =  person.confirmed_notification_email_addresses.first || person.primary_email.try(:address)
        result = stripe_accounts_api.create(community_id: current_community.id, person_id: person.id, body: account_attrs)
        if result[:success]
          @just_created = true
          load_stripe_account
        else
          @stripe_error = true
          @error_msg = result[:error_msg]
        end
      end
    end
  end

  def parse_create_params(params)
    allowed_params = params.permit(*StripeAccountForm.keys)
    allowed_params[:birth_date] = params["birth_date(1i)"].present? ? parse_date(params) : nil
    StripeAccountForm.new(allowed_params)
  end

  def parse_date(params)
    Date.new params["birth_date(1i)"].to_i, params["birth_date(2i)"].to_i, params["birth_date(3i)"].to_i
  end

  def stripe_accounts_api
    StripeService::API::Api.accounts
  end

  def stripe_api
    StripeService::API::Api.wrapper
  end

  StripeBankForm = FormUtils.define_form("StripeBankForm",
        :bank_country,
        :bank_currency,
        :bank_account_holder_name,
        :bank_account_number,
        :bank_routing_number,
        :bank_routing_1,
        :bank_routing_2
        ).with_validations do
    validates_presence_of :bank_country,
        :bank_currency,
        :bank_account_holder_name,
        :bank_account_number
    validates_inclusion_of :bank_country, in: StripeService::Store::StripeAccount::COUNTRIES
    validates_inclusion_of :bank_currency, in: StripeService::Store::StripeAccount::VALID_BANK_CURRENCIES
  end    

  def stripe_update_bank_account
    bank_params = StripeParseBankParams.new(parsed_seller_account: @parsed_seller_account, params: params).parse
    bank_form = StripeBankForm.new(bank_params)
    @extra_forms[:stripe_bank_form] = bank_form
    #render json: {error: "Your alredy have updated stripe bank account"}  if @stripe_account[:stripe_seller_id].present?
    return false unless @stripe_account[:stripe_seller_id].present?

    if bank_form.valid? && bank_form.bank_account_number !~ /\*/
      result = stripe_accounts_api.create_bank_account(community_id: current_community.id, person_id: Person.find_by_username(params[:id]), body: bank_form.to_hash)
      if result[:success]
        load_stripe_account
      else
        @stripe_error = true
        @error_msg = result[:error_msg]
      end  
    else
      @stripe_error = true
      @error_msg = bank_form.errors.messages.flatten.join(' ')
    end
  end

  class StripeParseBankParams
    attr_reader :bank_country, :bank_currency, :form_params, :parsed_seller_account
    def initialize(parsed_seller_account:, params:)
      @parsed_seller_account = parsed_seller_account
      @bank_country = parsed_seller_account[:address_country]
      @bank_currency = MarketplaceService::AvailableCurrencies::COUNTRY_CURRENCIES[@bank_country]
      @form_params = params[:stripe_bank_form]
    end

    def parse
      {
        bank_country: bank_country,
        bank_currency: bank_currency,
        bank_account_holder_name: parsed_seller_account[:legal_name],
        bank_account_number: parse_bank_account_number,
        bank_routing_number: parse_bank_routing_number,
        bank_routing_1: form_params[:bank_routing_1],
        bank_routing_2: form_params[:bank_routing_2],
      }
    end

    def parse_bank_routing_number
      if bank_country == 'NZ'
        bank_branch, = form_params[:bank_account_number].split('-')
        bank_branch
      elsif form_params[:bank_routing_1].present?
        [form_params[:bank_routing_1], form_params[:bank_routing_2]].join("-")
      else
        form_params[:bank_routing_number]
      end
    end

    def parse_bank_account_number
      if bank_country == 'NZ'
        _, account, sufix = form_params[:bank_account_number].split('-')
        "#{account}#{sufix}"
      else
        form_params[:bank_account_number]
      end
    end
  end  

  def parse_stripe_seller_account(account)
    bank_record = account.external_accounts.select{|x| x["default_for_currency"] }.first || {}
    bank_number = if bank_record.present?
      [bank_record["country"], bank_record["bank_name"], bank_record["currency"], "****#{bank_record['last4']}"].join(", ").upcase
    end
    {
      legal_name: [account.legal_entity.first_name,  account.legal_entity.last_name].join(" "),

      address_city: account.legal_entity.address.city,
      address_state: account.legal_entity.address.state,
      address_country: account.legal_entity.address.country,
      address_line1: account.legal_entity.address.line1,
      address_postal_code: account.legal_entity.address.postal_code,

      bank_number_info: bank_number,
      bank_currency: bank_record ? bank_record["currency"] : nil
    }

  end

  StripeAddressForm = FormUtils.define_form("StripeAddressForm",
        :address_city,
        :address_line1,
        :address_postal_code,
        :address_state).with_validations do
    validates_presence_of :address_city, :address_line1, :address_postal_code
  end

  def stripe_update_address
    return unless @stripe_account[:stripe_seller_id].present?

    address_attrs = params.require(:stripe_address_form).permit(:address_line1, :address_city, :address_state, :address_postal_code)
    @extra_forms[:stripe_address_form] = StripeAddressForm.new(address_attrs)
    result = stripe_accounts_api.update_address(community_id: current_community.id, person_id: Person.find_by_username(params[:id]), body: address_attrs)
    if result[:success]
      load_stripe_account
    else
      @stripe_error = true
      @error_msg = result[:error_msg]
    end
  end          
end
