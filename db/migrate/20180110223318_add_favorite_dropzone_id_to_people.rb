class AddFavoriteDropzoneIdToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :favorite_dropzone_id, :integer
  end
end
