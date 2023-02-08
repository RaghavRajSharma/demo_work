# == Schema Information
#
# Table name: disciplines
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Discipline < ApplicationRecord
  has_many :people_disciplines 
  has_many :people, :through => :people_disciplines
  has_many :favorites, :class_name => 'Person', foreign_key: 'favorite_discipline_id'
end
