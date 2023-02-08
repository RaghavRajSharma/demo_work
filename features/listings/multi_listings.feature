Feature: User creates a Parent Listing 
  In order to create child listings that belong to one parent (packaged) listing, 
  a User will create a parent listing first, then add child listings to it.

  @javascript 
  Scenario: Adding child listings (willing to piece) to an existing full rig listing
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Containers"
    And there is a custom text field "Model" in community "test" in category "Containers"
    And there is a custom text field "Container Size" in community "test" in category "Containers"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Full Rigs" from listing type menu
    And I select "Selling" from listing type menu
    And I fill in "listing_title" with "My Awesome Rig"
    And I fill in "listing_description" with "Best Rig ever!!!!"
    And I press "Save listing"
    And I am on the home page
    And I click the link to the "My Awesome Rig" listing
    And I create a new child listing and select not willing to piece
    And I select "Selling" from listing type menu
    And I select "Mirage Systems" for the "Manufacturer" variable custom field
    And I select "Mirage G2" for the "Model" variable custom field
    And I select "MXS" for the "Container Size" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "Mirage G2 MXS" belongs to the listing titled "My Awesome Rig"
    And I see both "Mirage G2 MXS" and "My Awesome Rig" on the multi listing show page
    Given there is a custom text field "Manufacturer" in community "test" in category "Main"
    And there is a custom text field "Model" in community "test" in category "Main"
    And there is a custom text field "Size" in community "test" in category "Main"
    And I refresh custom field ids
    When I create a new child listing and select willing to piece
    And I select "Selling" from listing type menu
    And I select "Aerodyne" for the "Manufacturer" variable custom field
    And I select "Pilot" for the "Model" variable custom field
    And I select "104" for the "Size" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "Pilot 104" belongs to the listing titled "My Awesome Rig"
    Given there is a custom text field "Manufacturer" in community "test" in category "Reserve"
    And there is a custom text field "Model" in community "test" in category "Reserve"
    And there is a custom text field "Size" in community "test" in category "Reserve"
    And I refresh custom field ids
    When I create a new child listing and select willing to piece
    And I select "Selling" from listing type menu
    And I select "Aerodyne" for the "Manufacturer" variable custom field
    And I select "SmartLPV" for the "Model" variable custom field
    And I select "135" for the "Size" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "SmartLPV 135" belongs to the listing titled "My Awesome Rig"
    Given there is a custom text field "Manufacturer" in community "test" in category "AADs"
    And there is a custom text field "Model" in community "test" in category "AADs"
    And I refresh custom field ids
    When I create a new child listing and select willing to piece
    And I select "Selling" from listing type menu
    And I select "Advanced Aerospace Design (Vigil)" for the "Manufacturer" variable custom field
    And I select "Vigil" for the "Model" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "Vigil" belongs to the listing titled "My Awesome Rig"
    And the listing titled "Mirage G2 MXS" is "Open"
    And the listing titled "Pilot 104" is "Open"
    And the listing titled "SmartLPV 135" is "Open"
    And the listing titled "Vigil" is "Open"
    When I remove all child listings
    Then I should not see "Mirage G2 MXS"
    And I should not see "Pilot 104"
    And I should not see "SmartLPV 135"
    And I should not see "Vigil"
    When I follow the first "Add Existing Item"
    And I choose "Mirage G2 MXS"
    And I press submit
    And I wait for AJAX
    Then I should see "Mirage G2 MXS"
    When I follow the first "Add Existing Item"
    And I choose "Pilot 104"
    And I press submit
    And I wait for AJAX
    Then I should see "Pilot 104"
    When I follow the first "Add Existing Item"
    And I choose "SmartLPV 135"
    And I press submit
    And I wait for AJAX
    Then I should see "SmartLPV 135"
    When I follow the first "Add Existing Item"
    And I choose "Vigil"
    And I press submit
    And I wait for AJAX
    Then I should see "Vigil"


@javascript 
  Scenario: Adding child listings (not willing to piece) to an existing full rig listing
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Containers"
    And there is a custom text field "Model" in community "test" in category "Containers"
    And there is a custom text field "Container Size" in community "test" in category "Containers"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Full Rigs" from listing type menu
    And I select "Selling" from listing type menu
    And I fill in "listing_title" with "My Awesome Rig"
    And I fill in "listing_description" with "Best Rig ever!!!!"
    And I press "Save listing"
    And I am on the home page
    And I click the link to the "My Awesome Rig" listing
    And I create a new child listing and select not willing to piece
    And I select "Selling" from listing type menu
    And I select "Mirage Systems" for the "Manufacturer" variable custom field
    And I select "Mirage G2" for the "Model" variable custom field
    And I select "MXS" for the "Container Size" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "Mirage G2 MXS" belongs to the listing titled "My Awesome Rig"
    And I see both "Mirage G2 MXS" and "My Awesome Rig" on the multi listing show page
    Given there is a custom text field "Manufacturer" in community "test" in category "Main"
    And there is a custom text field "Model" in community "test" in category "Main"
    And there is a custom text field "Size" in community "test" in category "Main"
    And I refresh custom field ids
    When I create a new child listing and select not willing to piece
    And I select "Selling" from listing type menu
    And I select "Aerodyne" for the "Manufacturer" variable custom field
    And I select "Pilot" for the "Model" variable custom field
    And I select "104" for the "Size" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "Pilot 104" belongs to the listing titled "My Awesome Rig"
    Given there is a custom text field "Manufacturer" in community "test" in category "Reserve"
    And there is a custom text field "Model" in community "test" in category "Reserve"
    And there is a custom text field "Size" in community "test" in category "Reserve"
    And I refresh custom field ids
    When I create a new child listing and select not willing to piece
    And I select "Selling" from listing type menu
    And I select "Aerodyne" for the "Manufacturer" variable custom field
    And I select "SmartLPV" for the "Model" variable custom field
    And I select "135" for the "Size" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "SmartLPV 135" belongs to the listing titled "My Awesome Rig"
    Given there is a custom text field "Manufacturer" in community "test" in category "AADs"
    And there is a custom text field "Model" in community "test" in category "AADs"
    And I refresh custom field ids
    When I create a new child listing and select not willing to piece
    And I select "Selling" from listing type menu
    And I select "Advanced Aerospace Design (Vigil)" for the "Manufacturer" variable custom field
    And I select "Vigil" for the "Model" variable custom field
    And I wait for 2 seconds
    And I press "Save listing"
    Then the listing titled "Vigil" belongs to the listing titled "My Awesome Rig"
    And the listing titled "Mirage G2 MXS" is "Closed"
    And the listing titled "Pilot 104" is "Closed"
    And the listing titled "SmartLPV 135" is "Closed"
    And the listing titled "Vigil" is "Closed"

  