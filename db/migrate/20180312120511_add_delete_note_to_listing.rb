class AddDeleteNoteToListing < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :delete_note, :text
  end
end
