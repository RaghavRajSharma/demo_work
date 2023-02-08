class ChangeUserStatusToStatus < ActiveRecord::Migration[5.1]
  def change
    rename_column :people, :user_status_id, :status_id
  end
end
