class AddApiTokenToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :api_token, :string
    add_column :people, :api_token_created_at, :datetime
  end
end
