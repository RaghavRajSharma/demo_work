# == Schema Information
#
# Table name: drop_zones
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  street_address :text(65535)
#  city           :string(255)
#  state          :string(255)
#  zip_code       :string(255)
#  continent      :string(255)
#  planet         :string(255)
#  galaxy         :string(255)
#  country_code   :string(255)
#  phone_number   :string(255)
#  email          :string(255)
#  website        :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  country        :string(255)
#

require 'rails_helper'

RSpec.describe DropZone, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
