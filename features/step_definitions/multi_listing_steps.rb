When /^I click the link to the "(.*?)" listing?$/ do |listing_title|
  listing = Listing.find_by(title: listing_title)
  url = listing_path("en", listing)
  find("a[href='#{url}']").click
end

When /^I create a new child listing and select willing to piece?$/ do 
  first("a.willing-to-piece").click
end

When /^I create a new child listing and select not willing to piece?$/ do 
  first("a.not-willing-to-piece").click
end

When /^I remove all child listings$/ do
  page.all(".remove-child").each do |remove_link|
    remove_link.click
  end
end

When /^I wait for AJAX$/ do 
  wait_for_ajax
end

Then /^the listing titled "(.*?)" belongs to the listing titled "(.*?)"?$/ do |child_listing_title, parent_listing_title|
  child_listing = Listing.find_by(title: child_listing_title)
  parent_listing = Listing.find_by(title: parent_listing_title)
  expect(child_listing.parent_id).to be(parent_listing.id)
end

Then /^I see both "(.*?)" and "(.*?)" on the multi listing show page?$/ do |child_listing_title, parent_listing_title|
  parent_listing = Listing.find_by(title: parent_listing_title)
  expect(page).to have_content(child_listing_title)
  expect(page).to have_content(parent_listing_title)
  expect(page.current_path).to eq(listing_path("en", parent_listing))
end

Then /^the listing titled "(.*?)" is "(.*?)"$/ do |listing_title, status|
  listing = Listing.find_by(title: listing_title)
  if status.downcase == "open"
    expect(listing.open).to be(true)
  else 
    expect(listing.open).to be(false)
  end
end

