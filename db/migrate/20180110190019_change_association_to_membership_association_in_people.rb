class ChangeAssociationToMembershipAssociationInPeople < ActiveRecord::Migration[5.1]
  def change
    rename_column :people, :association, :membership_association
  end
end
