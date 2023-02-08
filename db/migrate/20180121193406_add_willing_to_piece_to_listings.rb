class AddWillingToPieceToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :willing_to_piece, :boolean, :default => true
  end
end
