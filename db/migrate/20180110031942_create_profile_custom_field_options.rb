class CreateProfileCustomFieldOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :profile_custom_field_options do |t|
      t.string :name
      t.integer :profile_custom_field_id

      t.timestamps
    end
  end
end
