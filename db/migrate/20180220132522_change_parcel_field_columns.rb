class ChangeParcelFieldColumns < ActiveRecord::Migration[5.1]
  def change
    change_column :listings, :length, :float
    change_column :listings, :width, :float
    change_column :listings, :height, :float
    change_column :listings, :weight, :float
  end
end
