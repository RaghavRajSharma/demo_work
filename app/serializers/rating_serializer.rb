# == Schema Information
#
# Table name: ratings
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RatingSerializer < ActiveModel::Serializer
  attributes :id
end
