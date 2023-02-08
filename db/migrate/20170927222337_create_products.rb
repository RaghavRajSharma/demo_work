class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.integer :category_id, index: true
      t.string :manufacturer
      t.string :model

      t.timestamps
    end
  end
end
