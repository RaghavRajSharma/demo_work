# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

RSpec.describe Status, type: :model do
  let(:person) { FactoryGirl.create(:person) }
  let(:status) { FactoryGirl.create(:status) }

  it "has many people" do 
    person.status_id = status.id 
    person.save
    expect(status.people).to include(person)
  end
end
