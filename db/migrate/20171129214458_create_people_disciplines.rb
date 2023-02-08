class CreatePeopleDisciplines < ActiveRecord::Migration[5.1]
  def change
    create_table :people_disciplines do |t|
      t.integer :person_id
      t.integer :discipline_id

      t.timestamps
    end
  end
end
