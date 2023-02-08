class AddProfessiontoPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :profession, :string
  end
end
