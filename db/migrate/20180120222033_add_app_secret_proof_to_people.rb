class AddAppSecretProofToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :app_secret_proof, :string
  end
end
