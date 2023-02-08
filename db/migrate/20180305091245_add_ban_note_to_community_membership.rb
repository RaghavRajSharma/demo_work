class AddBanNoteToCommunityMembership < ActiveRecord::Migration[5.1]
  def change
    add_column :community_memberships, :ban_note, :text
  end
end
