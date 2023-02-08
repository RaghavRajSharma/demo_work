class AddKnownContainerSizeAndKnownHarnessSizeToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :known_container_size, :boolean, default: false
    add_column :listings, :known_harness_size, :boolean, default: false
  end
end
