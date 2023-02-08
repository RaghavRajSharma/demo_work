# == Schema Information
#
# Table name: profile_custom_fields
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProfileCustomField < ApplicationRecord
  has_many :options, :class_name => "ProfileCustomFieldOption", :foreign_key => "profile_custom_field_id"
end
