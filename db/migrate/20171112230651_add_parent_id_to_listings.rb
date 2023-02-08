class AddParentIdToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :parent_id, :integer
  end
end
