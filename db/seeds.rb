require File.expand_path("../../config/environment", __FILE__)
require_relative './seed_helpers/setup_marketplace'
require_relative './seed_helpers/add_categories'
require_relative './seed_helpers/add_custom_fields'
require_relative './seed_helpers/add_products'
require_relative './seed_helpers/community_config'
require_relative './seed_helpers/configure_stripe'
require_relative './seed_helpers/add_listings'
require_relative './seed_helpers/add_profile_custom_fields'

# comment/uncomment these methods to control what rake db:seed will do
setup_marketplace
add_categories
add_custom_fields
add_products
community_config
configure_stripe
add_listings
add_profile_custom_fields
