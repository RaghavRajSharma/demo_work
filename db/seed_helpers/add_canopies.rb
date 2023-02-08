
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/canopies'

def add_canopies 
  Category.find_by_url("canopies").subcategories.each do |sub|
    sub.products.each { |p| p.destroy }
  end
  canopies.each do |canopy| 
    Product.new_from_hash(canopy)
  end
end