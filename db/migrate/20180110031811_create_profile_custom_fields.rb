class CreateProfileCustomFields < ActiveRecord::Migration[5.1]
  def change
    create_table :profile_custom_fields do |t|
      t.string :name

      t.timestamps
    end
  end
end
