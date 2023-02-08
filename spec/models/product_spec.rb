# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  category_id  :integer
#  manufacturer :string(255)
#  model        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#

require 'spec_helper'

RSpec.describe Product, type: :model do

  before(:each) do 
    @product = FactoryGirl.create(:product)
  end

  after(:each) do 
    @product.destroy
  end

  describe "validations" do 
    
    it "must be unique by model name and manufacturer" do 
      @duplicate = FactoryGirl.build(:product)
      expect(@duplicate).not_to be_valid
    end

    it "allows for duplicate model names of different manufacturers" do 
      @almost_duplicate = FactoryGirl.build(:product)
      @almost_duplicate.manufacturer = "Firebird"
      expect(@almost_duplicate).to be_valid
    end

    it "is not valid without a category" do 
      @product.category_id = nil
      expect(@product).not_to be_valid
    end

    it "is not valid without a manufacturer" do 
      @product.manufacturer = nil 
      expect(@product).not_to be_valid
    end

    it "is not valid without a model" do 
      @product.model = nil 
      expect(@product).not_to be_valid
    end

    it "is valid with all normal attributes" do
      expect(@product).to be_valid
    end
  end

  describe "associations" do 
    before(:each) do 
      @product = FactoryGirl.create(:product_with_variations)
    end
    it "has many variations" do 
      expect(@product.variations.count).to be(20)
      @product.destroy
    end
  end

  describe "methods" do 
    before(:each) do 
      @product = FactoryGirl.create(:product_with_variations)
    end

    after(:each) do 
      @product.destroy
    end

    describe "#options_for(attribute)" do 
      it "filters variations by attribute" do 
        expect(@product.options_for("size").count).to eq(10)
      end
    end

    describe "#options" do 
      it "returns a hash with all attribute_names as keys and their options as values" do 
        expect(@product.options.keys.count).to eq(2)
        expect(@product.options.keys.first).to eq("size")
        expect(@product.options.keys.last).to eq("color")
        expect(@product.options.values.first).to eq(@product.options_for("size"))
        expect(@product.options.values.last).to eq(@product.options_for("color"))
      end
    end

  end

end
