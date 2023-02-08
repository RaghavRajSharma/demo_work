# == Schema Information
#
# Table name: ratings
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

RSpec.describe Rating, type: :model do
  before(:all) do
    #These will be created only once for the whole example group
    @test_person = FactoryGirl.create(:person)
    @rating = Rating.create(name: "Master Rigger")
  end

  it "has many people through people ratings" do 
    @people_rating = PeopleRating.create(person_id: @test_person.id, rating_id: @rating.id)
    @rating.save 
    expect(@rating.people_ratings).to include(@people_rating)
    expect(@rating.people).to include(@test_person)
  end
end
