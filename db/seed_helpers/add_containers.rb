require File.expand_path("../../../config/environment", __FILE__)
require_relative "./data/containers"

def add_containers 
  Category.find_by_url("containers").products.each do |p|
    p.destroy 
  end 
  containers.each do |container|
    Product.new_from_hash(container)
  end
end