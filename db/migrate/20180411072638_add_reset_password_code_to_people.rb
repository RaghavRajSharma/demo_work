class AddResetPasswordCodeToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :reset_password_code, :string
  end
end
