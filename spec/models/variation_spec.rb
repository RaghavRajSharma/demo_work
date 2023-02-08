# == Schema Information
#
# Table name: variations
#
#  id             :integer          not null, primary key
#  product_id     :integer
#  attribute_name :string(255)
#  value          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_variations_on_product_id  (product_id)
#

require 'spec_helper'

RSpec.describe Variation, type: :model do
  before(:each) do 
    @product = FactoryGirl.create(:product_with_variations)
    @variation = @product.variations.first
  end

  describe "validations" do 
    it "is invalid without a product" do 
      @variation.product = nil 
      expect(@variation).not_to be_valid
    end

    it "is invalid without an attribute name" do 
      @variation.attribute_name = nil 
      expect(@variation).not_to be_valid
    end

    it "is invalid without a value" do 
      @variation.value = nil 
      expect(@variation).not_to be_valid
    end

    it "is valid with all required attributes" do 
      expect(@variation).to be_valid
    end
  end
end
