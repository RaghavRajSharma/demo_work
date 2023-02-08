# == Schema Information
#
# Table name: profile_custom_field_options
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  profile_custom_field_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class ProfileCustomFieldOption < ApplicationRecord
  belongs_to :field, :class_name => "ProfileCustomField", :foreign_key => "profile_custom_field_id"
end
