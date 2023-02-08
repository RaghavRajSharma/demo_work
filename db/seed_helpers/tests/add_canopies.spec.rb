require 'rspec'
require File.expand_path("../../../../config/environment", __FILE__)
require_relative '../add_canopies'
require_relative '../data/canopies'

describe "Product" do 
  before(:each) do 
    Product.all.each { |p| p.destroy } 
  end
  describe ".new_from_hash(hash)" do 
    it "creates a new product and its variations from a hash" do 
      canopy = canopies.first
      @product = Product.new_from_hash(canopy)
      expect(@product.category).to eq(Category.find_by_url("main"))
      expect(@product.manufacturer).to eq("Aerodyne")
      expect(@product.model).to eq("Pilot")
      expect(@product.options_for('Size').size).to eq(14)
      canopy["Size"].split(',').map(&:strip).each_with_index do |size, index|
        expect(@product.options_for('Size')[index]).to eq(size)
      end
    end

    it "stores different variations for products in the same category" do 
      canopy = canopies[1]
      @product = Product.new_from_hash(canopy)
      expect(@product.category).to eq(Category.find_by_url("main"))
      expect(@product.manufacturer).to eq("Aerodyne")
      expect(@product.model).to eq("Pilot7")
      expect(@product.options_for('Size').size).to eq(8)
      canopy["Size"].split(',').map(&:strip).each_with_index do |size, index|
        expect(@product.options_for('Size')[index]).to eq(size)
      end
    end

    it "can store two of the same model names that have a different category" do 
      cricket_main = {
        "Manufacturer" => "Flight Concepts",
        "Model" => "Cricket",
        "Type" => "Main",
        "Size" => "145"
      }
      cricket_reserve = {
        "Manufacturer" => "Flight Concepts",
        "Model" => "Cricket",
        "Type" => "Reserve",
        "Size" => "145"
      }
      @cricket_main = Product.new_from_hash(cricket_main)
      @cricket_reserve = Product.new_from_hash(cricket_reserve)
      expect(@cricket_main).to be_valid
      expect(@cricket_reserve).to be_valid
      expect(@cricket_main.category).to eq(Category.find_by_url("main"))
      expect(@cricket_reserve.category).to eq(Category.find_by_url("reserve"))
    end
  end
end