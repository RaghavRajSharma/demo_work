# == Schema Information
#
# Table name: disciplines
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

RSpec.describe Discipline, type: :model do
  before(:all) do
    #These will be created only once for the whole example group
    @test_person = FactoryGirl.create(:person)
    @discipline = Discipline.create(name: "Bellyflying")
  end
  it "has many people, through people_disciplines" do 
    @people_discipline = PeopleDiscipline.create(:person_id => @test_person.id, :discipline_id => @discipline.id)
    expect(@discipline.people_disciplines).to include(@people_discipline)
    expect(@discipline.people).to include(@test_person)
  end
end
