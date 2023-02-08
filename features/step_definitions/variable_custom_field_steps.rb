Given /^I refresh custom field ids$/ do 
  Product.refresh_custom_field_ids
  CategoryVariableCustomField.update_associations(debug: false)
end

When /^I select "(.*?)" for the "(.*?)" variable custom field?$/ do |option, custom_field_name|
  selector = "select.#{custom_field_name.downcase.split(' ').join('-')}"
  find(selector).find(:option, option).select_option
  
end

Then /^I see a list of Manufacturers for the "(.*?)" category$/ do |category_name|
  category = Category.find_by_name(category_name)
  manufacturers = Product.manufacturers_by_category(category.id)
  manufacturers.each do |manufacturer|
    expect(page).to have_content(manufacturer)
  end
end

Then /^I see a list of Models made by "(.*?)" for the "(.*?)" category$/ do |manufacturer_name, category_name|
  category = Category.find_by_name(category_name)
  models = Product.models_by_manufacturer_and_category(category.id, manufacturer_name)
  models.each do |model| 
    expect(page).to have_content(model)
  end
end

Then /^I see a list of Sizes for the "(.*?)" model made by "(.*?)" for the "(.*?)" category$/ do |model_name, manufacturer_name, category_name|
  category = Category.find_by_name(category_name)
  sizes = Product.category_manufacturer_model_sizes(category.id, manufacturer_name, model_name)
  sizes.each do |size| 
    expect(page).to have_content(size)
  end
end

Then /^the listing title field should have "(.*?)" as a value$/ do |field_value|
  expect(find('#listing_title').value).to eq(field_value)
end

#And I fill in custom text field "Manufacturer" with "My Manufacturer"
When /^(?:|I )fill in custom text field "([^"]*)" with "([^"]*)"$/ do |field_name, value|
  field_id = find_custom_field_by_name(field_name).id
  fill_in("custom_fields_#{field_id}_text", :with => value)
end