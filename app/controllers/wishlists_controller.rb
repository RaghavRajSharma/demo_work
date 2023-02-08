class WishlistsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action do |controller|
    controller.ensure_logged_in t('layouts.notifications.you_must_log_in_to_view_this_content')
  end

  def add
    toggle_add_remove('add')
    @current_user.follow(listing) unless @current_user.is_following?(listing)
  end

  def remove
    toggle_add_remove('remove')
    @current_user.unfollow(listing) if @current_user.is_following?(listing)
  end

  private

  def toggle_add_remove(action)
    toggled = ToggleListingWishlist.call(action, listing, @current_user)

    respond_to do |format|
      format.js do
        render layout: false, template: 'wishlists/wishlist_add_remove', locals: { listing: listing }
      end
    end
  end

  def listing
    @listing ||= Listing.find(params[:listing_id])
  end
end
