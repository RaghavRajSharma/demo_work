class AddSoldToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :sold, :boolean, :default => false
  end
end
