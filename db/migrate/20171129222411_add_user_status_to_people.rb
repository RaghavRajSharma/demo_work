class AddUserStatusToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :user_status_id, :integer
  end
end
