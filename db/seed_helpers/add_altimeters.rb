
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/altimeters'

def add_altimeters 
  Category.find_by_url("altimeters").subcategories.each do |sub|
    sub.products.each { |p| p.destroy }
  end
  altimeters.each do |altimeter| 
    Product.new_from_hash(altimeter)
  end
end