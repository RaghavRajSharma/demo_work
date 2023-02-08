class Api::V1::WishlistsController < Api::V1::BaseController
  swagger_controller :Wishlists, 'Wishlists'
  before_action :get_listing
  before_action :get_follower

  swagger_api :add do
    summary "Add Wishlists"
    param :form, :id, :integer, :required, "Listing id"
    param :form, :follower_id, :string, :required, "follower_id as username of person"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable    
  end

  def add
    wishlist_added = toggle_add_remove('add',@listing,@follower)
    followed_listing = @follower.follow(@listing) unless @follower.is_following?(@listing)
    if wishlist_added && followed_listing
      render json: {success: "Listing added in wishlists successfully"}, status: 200
    else
      render json: {error: "Something went wrong, please try later!"}, status: 404
    end
  end  
  
  swagger_api :remove do
    summary "Remove Wishlists"
    param :path, :id, :integer, :required, "Listing id"
    param :form, :follower_id, :string, :required, "follower_id as username of person"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable    
  end

  def remove
    removed_wishlist = toggle_add_remove('remove', @listing, @follower)
    unfollowed_listing = @follower.unfollow(@listing) if @follower.is_following?(@listing)
    render json: {success: "Listing removed from wishlists successfully"}, status: 200
  end

  private

    def toggle_add_remove(action,listing,follower)
      toggled = ToggleListingWishlist.call(action,listing,follower)
    end  

    def get_listing
      @listing ||= Listing.find(params[:id])
      unless @listing.present?
        render json: {error: "listing not found."}, status: 404
      end
    end

    def get_follower
      @follower = Person.find_by!(username: params[:follower_id], community_id: current_community.id) 
      unless @follower.present?
        render json: {error: "follower not found."}, status: 404
      end
    end
end
