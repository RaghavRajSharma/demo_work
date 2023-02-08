class ChangeYearsInSportToJumpingSinceInPeople < ActiveRecord::Migration[5.1]
  def change
    remove_column :people, :years_in_sport
    add_column :people, :jumping_since, :integer
  end
end
