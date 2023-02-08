class AddWishlistsCountToListingAndPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :wishlists_count, :integer, default: 0
    add_column :listings, :wishlists_count, :integer, default: 0
  end
end
