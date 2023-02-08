# pull in all of products by category
require_relative './add_aads'
require_relative './add_altimeters'
require_relative './add_cameras'
require_relative './add_canopies'
require_relative './add_containers'
require_relative './add_helmets'
require_relative './add_jumpsuits'

def add_products
  add_aads
  add_altimeters
  add_cameras
  add_canopies
  add_containers
  add_helmets
  add_jumpsuits
end