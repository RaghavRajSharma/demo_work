class CreatePeopleRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :people_ratings do |t|
      t.integer :person_id 
      t.integer :rating_id
      t.timestamps
    end
  end
end
