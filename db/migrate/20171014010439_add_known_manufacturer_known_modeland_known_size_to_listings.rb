class AddKnownManufacturerKnownModelandKnownSizeToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :known_manufacturer, :boolean, default: false
    add_column :listings, :known_model, :boolean, default: false
    add_column :listings, :known_size, :boolean, default: false
  end
end
