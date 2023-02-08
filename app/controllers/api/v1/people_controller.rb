class Api::V1::PeopleController < Api::V1::BaseController
  swagger_controller :people, 'People'

  swagger_api :create do
    summary "Signup API"
    notes "Allow user to signup with email, username, given_name, family_name, password and password2"
    param :form, :email, :string, :required, "Email"
    param :form, :given_name, :string, :required, "First Name"
    param :form, :family_name, :string, :required, "Last Name"
    param :form, :username, :string, :required, "Username"
    param :form, :password, :string, :required, "Password"
    param :form, :password2, :string, :required, "Password2"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :show do
    summary "Show Person"
    notes "Allow user to display his details and profile"
    param :path, :id, :string, :required, "Username"
    param :query, :current_user_id, :string, :optional, "Username of current user"
    response :unauthorized
    response :not_acceptable
  end


  swagger_api :show_listings do
    summary "Show All listings of a Person include closed"
    notes "Allow user to display his details and profile"
    param :path, :id, :string, :required, "Username"
    param :query, :show_closed, :boolean, :optional, "Show Closed"
    param :query, :show_all, :boolean, :optional, "Show All"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Update Person"
    notes "Allow user to update details with given_name, family_name, password and password2"
    param :path, :id, :string, :required, "Username"
    param :form, :given_name, :string, :optional, "First Name"
    param :form, :family_name, :string, :optional, "Last Name"
    param :form, :password, :string, :optional, "Password"
    param :form, :password2, :string, :optional, "Password2"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes an existing User item"
    param :path, :id, :string, :required, "Username"
    response :unauthorized
    response :not_acceptable
  end  

  swagger_api :verify do
    summary "Confirm an existing User"
    param :form, :confirmation_code, :string, :required, "Confirmation Code"
    response :unauthorized
    response :not_acceptable
  end 

  swagger_api :request_new_password do
    summary "This end point is used to request new password or for forgot password"
    param :form, :email, :string, :required, "Email"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update_password do
    summary "This end point is used to verify reset password code and update password"
    param :form, :reset_password_code, :string, :required, "Reset Password Code"
    param :form, :password, :string, :optional, "Password"
    param :form, :password2, :string, :optional, "Confirm Password"
    response :unauthorized
    response :not_acceptable
  end 

  swagger_api :check_email_availability_and_validity do
    summary "This end point is used to to check email availability and its validity"
    param :query, :email, :string, :required, "Email"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :check_username_availability do
    summary "This end point is used to to check username availability"
    param :query, :username, :string, :required, "Username"
    response :unauthorized
    response :not_acceptable
  end                 

  swagger_api :resend_confirmation_code do
    summary "This end point is used to resend confirmation_code for email verification."
    param :query, :email, :string, :required, "Email"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :person_follow_status do
    summary "Check following status"
    notes "This check if a user is following other user"
    param :path, :id, :string, :required, "Username of first user"
    param :query, :other_user_id, :string, :required, "Username of second user"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  def create
    unless params.values_at(:email, :given_name, :family_name, :username, :password, :password2).any?(&:nil?)
      email = params[:email].to_s.downcase
      if !(current_community.email_allowed?(email) && Email.email_available?(email, current_community.id))
        render json: {error: "The email you gave is already in use." }, status: 406
      elsif !(Person.username_available?(params[:username], current_community.id))
        render json: {error: "This username is already in use." }, status: 406
      else
        person = Person.new(person_params)
        person.locale = current_community.default_locale
        totp = ROTP::TOTP.new("base32secret3232")
        email = Email.new(:person => person, :address => person_params[:email].downcase, :send_notifications => true, community_id: current_community.id, confirmation_code: totp.now)
        person_params.delete(:email)
        person.emails << email
        person.inherit_settings_from(current_community)
        person.community_id = current_community.id
        if person.save!
          person.set_default_preferences
          # Make person a member of the current community
          if current_community
            membership = CommunityMembership.new(person: person, community: current_community, consent: current_community.consent)
            membership.status = "pending_email_confirmation"
            # If the community doesn't have any members, make the first one an admin
            if current_community.members.count == 0
              membership.admin = true
            end
            membership.save!
          end
          Delayed::Job.enqueue(CommunityJoinedJob.new(person.id, current_community.id)) if current_community
          # send email confirmation
          # (unless disabled for testing environment)
          if APP_CONFIG.skip_email_confirmation
            person.emails.last.confirm!
            render json: person, status: 200
          else
            Email.send_confirmation(person.emails.last, current_community)
            render json: { confirmation_pending: true }, status: 200
          end          
        else
          render json: {error: person.errors.full_messages.to_sentence }, status: 400
        end
      end  
    else
      render json: {error: "Incomplete Parameters!" }, status: 400
    end
  end

  def show
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    current_user = Person.find_by(username: params[:current_user_id])
    if person.present?
      if person.deleted?
        render json: {error: "The Person no longer exists!" }, status: 404
      elsif person.banned?
        render json: {error: "Sorry! But you are no longer authorize to access your account, Contact Admin for any kind of help!" }, status: 400
      else
        render json: person, serializer: PersonProfileSerializer, current_user: current_user, root: "person", status: 200
      end
    else
      render json: {error: "The Person no longer exists!" }, status: 404
    end
  end
  
  swagger_api :wishlists do
    summary "Show wishlist"
    param :path, :id, :string, :required, "Username of current user"
    response :unauthorized
    response :not_acceptable
  end

  def wishlists
    person = Person.find_by(username: params[:id], community_id: current_community.id)
    if person.present?
      listings = person.wishlist_listings
      unless listings.blank?
        search = {
          listing_ids: listings.pluck(:id),
          per_page: 1000,
          page: 1,
          include_closed: false
        }

        includes = [:author, :listing_images]

        wishlist_listings = ListingIndexService::API::Api
          .listings
          .search(
            community_id: current_community.id,
            search: search,
            engine: FeatureFlagHelper.search_engine,
            raise_errors: false,
            includes: includes
          ).and_then { |res|
          Result::Success.new(
            ListingIndexViewUtils.to_struct(
            result: res,
            includes: includes,
            page: search[:page],
            per_page: search[:per_page]
          ))
        }.data
      else
        wishlist_listings = []
      end

      render json: {listings: wishlist_listings}, status: 200
    else
      render json: {error: "person does not exists!"}, status: 404
    end
  end


  def person_follow_status
    follower = Person.find_by!(username: params[:id], community_id: current_community.id)
    following = Person.find_by!(username: params[:other_user_id], community_id: current_community.id)
    render json: follower.follows?(following)
  end

  def show_listings
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    per_page = params[:show_all] == 'true' ? 1000 : 6
    include_closed = params[:show_closed] == 'true' ? true : false

    if person.present?
      search = {
        author_id: person.id,
        include_closed: include_closed,
        page: 1,
        per_page: per_page
      }
      includes = [:author, :listing_images]
      listings = ListingIndexService::API::Api
        .listings
        .search(
          community_id: current_community.id,
          search: search,
          engine: FeatureFlagHelper.search_engine,
          raise_errors: false,
          includes: includes
        ).and_then { |res|
        Result::Success.new(
          ListingIndexViewUtils.to_struct(
          result: res,
          includes: includes,
          page: search[:page],
          per_page: search[:per_page]
        ))
      }.data
      render json: {listings: listings}, status: 200
    else
      render json: {error: "The Person no longer exists!" }, status: 404
    end
  end

  def update
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      if person.update_attributes(person_params.except(:email, :username))
        render json: person, status: 200
      else
        render json: {error: person.errors.full_messages.to_sentence }, status: 400
      end
    else
      render json: {error: "The Person no longer exists!" }, status: 404
    end
  end

  def destroy
    person = Person.find_by!(username: params[:id], community_id: current_community.id)
    if person.present?
      has_unfinished = TransactionService::Transaction.has_unfinished_transactions(person.id)
      if has_unfinished
        render json: {error: "Person has unfinished transactions" }, status: 400
      else
        begin
          # Do all delete operations in transaction. Rollback if any of them fails
          ActiveRecord::Base.transaction do
            UserService::API::Users.delete_user(person.id)
            MarketplaceService::Listing::Command.delete_listings(person.id)

            PaypalService::API::Api.accounts.delete(community_id: person.community_id, person_id: person.id)
          end
          render json: {success: "Person deleted successfully." }, status: 200          
        rescue => e
          render json: {error: person.errors.full_messages.to_sentence }, status: 400
        end  
      end  
    else
      render json: {error: "The Person doesn't exists!" }, status: 404
    end
  end

  def verify
    if params[:confirmation_code].present?
      e = Email.find_by(confirmation_code: params[:confirmation_code])
      if e.present?
        person = e&.person
        if person.present?
          if e.confirmation_code == params[:confirmation_code]
            e.confirmed_at = Time.now
            e.confirmation_token = nil
            e.confirmation_code = nil
            if e.save
              person.allow_token_to_be_used_only_once
              # Accept pending community membership if needed
              if current_community.approve_pending_membership(person, e.address)
                # If the pending membership was accepted now, it's time to send the welcome email, unless creating admin acocunt
                Delayed::Job.enqueue(SendWelcomeEmail.new(person.id, current_community.id), priority: 5)
              end
              render json: person, status: 200                
            else
              render json: {error: e.errors.full_messages.to_sentence }, status: 400
            end
          else
            render json: {error: "Invalid confirmation code!" }, status: 404
          end
        else
          render json: {error: "The Person doesn't exists!" }, status: 404
        end
      else
        render json: {error: "Invalid confirmation code!" }, status: 404
      end
    else
      render json: {error: "Please enter confirmation code!" }, status: 404
    end
  end

  def resend_confirmation_code
    email = Email.find_by(address: params[:email].to_s.downcase)
    if email.present?
      totp = ROTP::TOTP.new("base32secret3232")
      if email.update(confirmation_code: totp.now)
        render json: {success: "Confirmation code sent to your email successfully."}, status: 404
      else
        render json: {error: "Something went wrong, please try again!"}, status: 200
      end
    else
      render json: {error: "Given email is not registrated!"}
    end
  end

  def request_new_password
    person = Person.find_by_email_address_and_community_id(params[:email], current_community)
    if person.present?
      totp = ROTP::TOTP.new("base32secret3232")
      if person.update(reset_password_code: totp.now)
        token = person.reset_password_token_if_needed
        MailCarrier.deliver_later(PersonMailer.reset_password_instructions(person, params[:email], token, current_community))
        render json: {success: "Please check your email to get reset password code"},status: 200 
      else
        render json: {errors: person.errors.full_messages.to_sentence}, status: 404
      end
    else
      render json: {error: "Person not found!" }, status: 404
    end
  end

  def update_password
    unless params.values_at(:reset_password_code, :password, :password2).any?(&:nil?)
      person = Person.find_by(reset_password_code: params[:reset_password_code])
      if person.present?
        if params[:reset_password_code] == person.reset_password_code
          if params[:password] == params[:password2]
            person.password = params[:password]
            person.reset_password_token = nil
            person.reset_password_code = nil
            person.reset_password_sent_at = nil
            if person.save
              render json: {success: "Password updated successfully."}, status: 200
            else
              render json: {error: "Something went wrong, please try again."}, status: 404
            end
          else
            render json: {error: "password and confirmation password doesn't match!"},status: 404
          end  
        else
          render json: {error: "Reset password code does not match!"},status: 404
        end
      else
        render json: {error: "Invalid reset password code." }, status: 404
      end
    else
      render json: {error: "Please enter reset password code, password, and confirmation password!" }, status: 404
    end  
  end

  def check_email_availability_and_validity
    email =  params[:email].to_s.downcase
    allowed_and_available = current_community.email_allowed?(email) && Email.email_available?(email, current_community.id)
    if allowed_and_available
      render json: {success: "Email availabile."}, status: 200
    else
      render json: {error: "Email already in use!"}, status: 404
    end
  end 

  def check_username_availability
    is_availabile = Person.username_available?(params[:username], current_community.id)
    if is_availabile
      render json: {success: "Username availabile."}, status: 200
    else
      render json: {error: "Username already in use!"}, status: 404
    end  
  end

  swagger_api :mutual_friends do
    summary "Fecth Mutual Friends"
    notes "This end point is used to fetch facebook mutual friends of current user"
    param :path, :id, :string, :required, "Username of current user"
    param :query, :other_person_id, :string, :required, "Username of other person."
    response :unauthorized
    response :not_acceptable
  end  

  def mutual_friends
    current_user = Person.find_by(username: params[:id])
    other_user = Person.find_by(username: params[:other_person_id])
    if current_user.present? && other_user.present?
      if current_user.authentication_token.present?
        fb = FacebookService.new(access_token: current_user.authentication_token)
        if fb && current_user != other_user && other_user.authentication_token
          friends_in_common  = fb.mutual_friends(other_user.authentication_token)
          render json: friends_in_common, status: 200
        else
          render json: {error: "Authentication token is missing or both users are same or something went wrong"}, status: 404
        end
      else
        render json: {error: "Authentication token is missing"}, status: 404
      end  
    else
      render json: {error: "Please provide current user and other user"}, status: 200
    end
  end   

private
  def person_params
    params.delete(:id)
    params.permit(:email, :given_name, :family_name, :username, :password, :password2)
  end    
end