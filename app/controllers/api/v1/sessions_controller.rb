class Api::V1::SessionsController < Api::V1::BaseController
  swagger_controller :sessions, 'Sessions'
  before_action :require_login, only: [:destroy]

  swagger_api :create do
    summary "User login"
    notes "Allow user to login with email and password"
    param :form, :email, :string, :required, "Email"
    param :form, :password, :string, :required, "Password"
    response :unauthorized
    response :not_acceptable
  end
  
  def create
    if person = Person.valid_login?(params[:email], params[:password])
      person.allow_token_to_be_used_only_once
      render json: person, status: 200
    else
      render_unauthorized("Error with your login or password")
    end
  end

  swagger_api :destroy do
    summary "Logout"
    notes "Logout user"
    param :query, :api_token, :string, :required, "API Token"
    response :unauthorized
  end

  def destroy
    current_api_user.logout
    head :ok
  end

  swagger_api :facebook do
    summary "Facebook Signup/Login"
    notes "Login with facebook"
    param :form, :email, :string, :required, "Email"
    param :form, :given_name, :string, :required, "First Name"
    param :form, :family_name, :string, :required, "Last Name"
    param :form, :username, :string, :optional, "Username"
    param :form, :facebook_id, :string, :required, "Facebook ID/UID"
    param :form, :authentication_token, :string, :required, "Facebook authentication token"
    response :unauthorized
  end

  def facebook
    person = Email.find_by(address: params[:email])&.person
    if person.present?
      person.update(facebook_id: params[:facebook_id], authentication_token: params[:authentication_token])
      person.allow_token_to_be_used_only_once
    else
      username = UserService::API::Users.username_from_fb_data(
        username:     params[:username] || nil,
        given_name:   params[:given_name],
        family_name:  params[:family_name],
        community_id: current_community.id
      )

      person_hash = {
        username:             username,
        given_name:           params[:given_name],
        family_name:          params[:family_name],
        facebook_id:          params[:facebook_id],
        authentication_token: params[:authentication_token],
        locale:               I18n.locale,
        test_group_number:    1 + rand(4),
        password:             Devise.friendly_token[0,20],
        community_id:         current_community.id
      }

      ActiveRecord::Base.transaction do
        person = Person.create!(person_hash)
        person.generate_app_secret_proof = person.authentication_token
        # We trust that Facebook has already confirmed these and save the user few clicks
        Email.create!(address: params[:email], send_notifications: true, person: person, confirmed_at: Time.now, community_id: current_community.id)

        person.set_default_preferences
        CommunityMembership.create(person: person, community: current_community, status: "accepted")
        person.allow_token_to_be_used_only_once
      end

      begin
        person.allow_token_to_be_used_only_once
        person.store_picture_from_facebook!
      rescue StandardError => e
        # We can just catch and log the error, because if the profile picture upload fails
        # we still want to make the user creation pass, just without the profile picture,
        # which user can upload later
        puts e.message
      end
    end

    if person.persisted?
      render json: person, status: 200
    else
      render json: { error: person.errors.full_messages.to_sentence }, status: 400
    end
  end

  private

    def homepage_listings
      ListingsFeedPresenter.new(current_community, current_community.shapes, current_community.transaction_processes, {page: 1, per_page: 24})
    end

end
