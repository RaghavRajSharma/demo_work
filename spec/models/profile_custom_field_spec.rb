# == Schema Information
#
# Table name: profile_custom_fields
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe ProfileCustomField, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
