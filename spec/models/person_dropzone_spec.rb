# == Schema Information
#
# Table name: person_dropzones
#
#  id          :integer          not null, primary key
#  dropzone_id :integer
#  person_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe PersonDropzone, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
