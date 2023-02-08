# == Schema Information
#
# Table name: ratings
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Rating < ApplicationRecord
  has_many :people_ratings 
  has_many :people, :through => :people_ratings
end
