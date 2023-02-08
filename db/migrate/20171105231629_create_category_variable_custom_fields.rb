class CreateCategoryVariableCustomFields < ActiveRecord::Migration[5.1]
  def change
    create_table :category_variable_custom_fields do |t|
      t.integer :category_id
      t.integer :custom_field_id

      t.timestamps
    end
  end
end
