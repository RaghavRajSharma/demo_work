class ChangeStreetAddressToTextInDropZones < ActiveRecord::Migration[5.1]
  def change
    change_column :drop_zones, :street_address, :text
  end
end
