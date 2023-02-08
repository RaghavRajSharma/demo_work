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

require 'rails_helper'

RSpec.describe ProfileCustomFieldOption, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
