class AddProductIdToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :product_id, :integer
  end
end
