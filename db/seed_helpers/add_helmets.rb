
require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/helmets'

def add_helmets
  Category.find_by_url("helmets").subcategories.each do |sub|
    sub.products.each { |p| p.destroy }
  end
  helmets.each do |helmet|
    Product.new_from_hash(helmet)
  end
end