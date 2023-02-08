class AddFavoriteDisciplineIdToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :favorite_discipline_id, :integer
  end
end
