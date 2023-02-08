class AddAssociationAndMembershipAndLicenseNumbersToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :association, :string
    add_column :people, :membership_number, :string
    add_column :people, :license_number, :string
  end
end
