require File.expand_path("../../../config/environment", __FILE__)
require_relative './data/cameras'

def add_cameras
  Category.find_by_url("cameras").subcategories.each do |cat|
    cat.products.each { |p| p.destroy }
  end
  cameras.each do |camera|
    Product.new_from_hash(camera)
  end
end