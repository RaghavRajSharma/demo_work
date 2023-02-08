class Api::V1::BaseController < ActionController::API
  include ActionController::Serialization
  include AbstractController::Helpers
  helper_method :current_community
  respond_to :json

  def require_login
    authenticate_token || render_unauthorized("Access denied")
  end

  def current_api_user
    @current_api_user ||= authenticate_token
  end

  def current_community
    @current_community ||= Community.last
  end

  def current_community_membership
    @current_community_membership ||= CommunityMembership.where(person_id: current_api_user.id, community_id: current_community.id, status: "accepted").first if current_api_user
  end

  #this method decode base64 string to file.
  def decode_image(file, model_object)
    decoded_image = Base64.decode64(file)
    if model_object.present?
      tmp_file = "#{Rails.root}/public/system/images/users/#{model_object.id}/original"
    else
      tmp_file = "#{Rails.root}/public/system/images/listings/original"
    end  
    dirname = File.dirname(tmp_file)
    unless File.directory?(dirname)
     FileUtils.mkdir_p(dirname)
    end
    if model_object.present?
      tmp_file = File.new("#{Rails.root}/public/system/images/users/#{model_object.id}/#{model_object.username}.jpg", "wb")
    else
      tmp_file = File.new("#{Rails.root}/public/system/images/listings/listing_image.jpg", "wb")
    end
    tmp_file.write(decoded_image)
    tmp_file
  end 
    
  protected

    def render_unauthorized(message)
      errors = { errors: [ { detail: message } ] }
      render json: errors, status: :unauthorized
    end

  private

    def authenticate_token
      if person = Person.with_unexpired_token(params[:api_token])
        # Compare the tokens in a time-constant manner, to mitigate timing attacks.
        ActiveSupport::SecurityUtils.secure_compare(
                        ::Digest::SHA256.hexdigest(params[:api_token]),
                        ::Digest::SHA256.hexdigest(person.api_token))
        person
      end
    end
end