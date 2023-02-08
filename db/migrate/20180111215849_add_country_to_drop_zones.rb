class AddCountryToDropZones < ActiveRecord::Migration[5.1]
  def change
    add_column :drop_zones, :country, :string
  end
end
