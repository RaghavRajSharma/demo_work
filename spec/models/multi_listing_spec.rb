require 'spec_helper'

describe Listing, type: :model do
  before(:each) do
    @parent = FactoryGirl.create(:listing, listing_shape_id: 123)
    @child1 = FactoryGirl.create(:listing, listing_shape_id: 123)
    @child2 = FactoryGirl.create(:listing, listing_shape_id: 123)
    @child3 = FactoryGirl.create(:listing, listing_shape_id: 123)
    [@child1, @child2, @child3].each do |child|
      child.parent = @parent
      child.save
    end
  end

  it 'listings can have many child listings' do
    expect(@parent.children.count).to eq(3)
    [@child1, @child2, @child3].each do |child|
      expect(child.parent).to be(@parent)
    end
  end
end