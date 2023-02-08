require 'rspec'
require File.expand_path("../../../../config/environment", __FILE__)
require_relative '../add_containers'
require_relative '../data/containers'

describe "Product" do 
  before(:each) do 
    Product.all.each { |p| p.destroy } 
  end
  describe ".new_from_hash(hash)" do 
    it "creates a new product and its variations from a hash" do 
      container = containers.first
      product = Product.new_from_hash(container)
      expect(product.category).to eq(Category.find_by_url("containers"))
      expect(product.manufacturer).to eq("Aerodyne")
      expect(product.model).to eq("Icon A")
      expect(product.options_for("Container Size").size).to eq(14)
      container["Container Size"].split(",").map(&:strip).each_with_index do |cs, index|
        expect(product.options_for("Container Size")[index]).to eq(cs)
      end
      expect(product.options_for('Harness Size').size).to eq(8)
      container["Harness Size"].split(",").map(&:strip).each_with_index do |hs, index|
        expect(product.options_for("Harness Size")[index]).to eq(hs)
      end
    end

    it "stores different variations for products in the same category" do 
      container = containers[1]
      product = Product.new_from_hash(container)
      expect(product.category).to eq(Category.find_by_url("containers"))
      expect(product.manufacturer).to eq('Aerodyne')
      expect(product.model).to eq('Icon V')
      expect(product.options_for('Container Size').size).to eq(14)
      container["Container Size"].split(",").map(&:strip).each_with_index do |cs, index|
        expect(product.options_for("Container Size")[index]).to eq(cs)
      end
      expect(product.options_for('Harness Size').size).to eq(8)
      container["Harness Size"].split(",").map(&:strip).each_with_index do |hs, index|
        expect(product.options_for("Harness Size")[index]).to eq(hs)
      end
    end

    it "adds containers properly" do 
      containers = Category.find_by_url("containers")
      add_containers 
      expect(containers.products.size).to eq(10)
    end
  end
end