class CreateDropZones < ActiveRecord::Migration[5.1]
  def change
    create_table :drop_zones do |t|
      t.string :name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :continent
      t.string :planet
      t.string :galaxy
      t.string :country_code
      t.string :phone_number
      t.string :email
      t.string :website

      t.timestamps
    end
  end
end
