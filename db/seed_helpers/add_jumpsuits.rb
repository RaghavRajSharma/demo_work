
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/jumpsuits'

def add_jumpsuits 
  Category.find_by_url("jumpsuits").subcategories.each do |sub|
    sub.products.each { |p| p.destroy }
  end
  jumpsuits.each do |jumpsuit| 
    Product.new_from_hash(jumpsuit)
  end
end