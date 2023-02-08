class AddLicenseTypeJumpNumberAndYearsInSportToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :license_type, :string
    add_column :people, :jump_number, :string
    add_column :people, :years_in_sport, :string
  end
end
