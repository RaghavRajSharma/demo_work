class ToggleListingWishlist
  ACTIONS = %w(add remove).freeze

  def initialize(action, listing, user)
    @action = action
    @listing = listing
    @user = user
  end

  def self.call(action, listing, user)
    new(action, listing, user).call
  end

  def call
    return unless ACTIONS.include?(@action)
    send(@action)
  end

  private

  def add
    return if @user.has_wishlist?(@listing.id)
    @user.wishlist_listings << @listing
  end

  def remove
    return unless @user.has_wishlist?(@listing.id)
    @user.wishlist_listings.delete(@listing)
  end
end
