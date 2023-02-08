class CreateVariations < ActiveRecord::Migration[5.1]
  def change
    create_table :variations do |t|
      t.integer :product_id
      t.string :attribute_name
      t.string :value

      t.timestamps
    end
    add_index :variations, :product_id
  end
end
