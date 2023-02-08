# == Schema Information
#
# Table name: people_disciplines
#
#  id            :integer          not null, primary key
#  person_id     :integer
#  discipline_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe PeopleDiscipline, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
