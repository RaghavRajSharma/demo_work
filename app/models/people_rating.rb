# == Schema Information
#
# Table name: people_ratings
#
#  id         :integer          not null, primary key
#  person_id  :integer
#  rating_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PeopleRating < ApplicationRecord
  belongs_to :person 
  belongs_to :rating
end
