
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/aads'

def add_aads 
  Category.find_by_url("aads").products.each do |p|
    p.destroy 
  end 
  aads.each do |aad| 
    Product.new_from_hash(aad)
  end
end