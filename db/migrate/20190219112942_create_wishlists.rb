class CreateWishlists < ActiveRecord::Migration[5.1]
  def change
    create_table :wishlists do |t|
      t.integer :listing_id
      t.string :person_id

      t.timestamps
    end
  end
end
