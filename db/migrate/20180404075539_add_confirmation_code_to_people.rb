class AddConfirmationCodeToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :emails, :confirmation_code, :string
  end
end
