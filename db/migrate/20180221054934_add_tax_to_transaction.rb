class AddTaxToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :tax_cents, :integer
  end
end
