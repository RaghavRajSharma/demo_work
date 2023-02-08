class AddShippingTrackingNumberToTransaction < ActiveRecord::Migration[5.1]
  def change
  	add_column :transactions, :shipping_tracking_number, :string
  end
end
