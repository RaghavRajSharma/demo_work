class AddCoverEnabledToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :cover_enabled, :boolean, default: false
  end
end
