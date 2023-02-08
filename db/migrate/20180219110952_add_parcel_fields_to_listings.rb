class AddParcelFieldsToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :length, :decimal
    add_column :listings, :width, :decimal
    add_column :listings, :height, :decimal
    add_column :listings, :weight, :decimal
  end
end
