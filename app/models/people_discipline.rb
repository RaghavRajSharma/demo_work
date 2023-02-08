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

class PeopleDiscipline < ApplicationRecord
  belongs_to :person
  belongs_to :discipline
end
