class CreatePersonDropzones < ActiveRecord::Migration[5.1]
  def change
    create_table :person_dropzones do |t|
      t.integer :dropzone_id
      t.integer :person_id

      t.timestamps
    end
  end
end
