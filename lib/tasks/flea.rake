namespace :flea do
  task "refresh_custom_field_ids" => :environment do
    Product.refresh_custom_field_ids
  end
end