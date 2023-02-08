Feature: Variable Custom Fields on New Listing Form 
  In order to guide the user when posting a new listing 
  a list of manufacturers, models and sizes of products 
  in that particular category are dynamically inserted  
  into the form

  @javascript 
  Scenario: User sees a list of manufacturers
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Main"
    And there is a custom text field "Model" in community "test" in category "Main"
    And there is a custom text field "Size" in community "test" in category "Main"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Canopies" from listing type menu
    And I select "Main" from listing type menu
    And I select "Selling" from listing type menu
    Then I see a list of Manufacturers for the "Main" category
    
  @javascript 
  Scenario: User sees a list of models after choosing a Manufacturer
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Main"
    And there is a custom text field "Model" in community "test" in category "Main"
    And there is a custom text field "Size" in community "test" in category "Main"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Canopies" from listing type menu
    And I select "Main" from listing type menu
    And I select "Selling" from listing type menu
    And I select "Aerodyne" for the "Manufacturer" variable custom field
    Then I see a list of Models made by "Aerodyne" for the "Main" category

  @javascript 
  Scenario: User sees a list of sizes after choosing a Manufacturer and Model
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Main"
    And there is a custom text field "Model" in community "test" in category "Main"
    And there is a custom text field "Size" in community "test" in category "Main"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Canopies" from listing type menu
    And I select "Main" from listing type menu
    And I select "Selling" from listing type menu
    And I select "Aerodyne" for the "Manufacturer" variable custom field
    And I select "Pilot7" for the "Model" variable custom field
    Then I see a list of Sizes for the "Pilot7" model made by "Aerodyne" for the "Main" category

  @javascript
  Scenario: Listing Title is blank when page loads on New Listing page for a Container
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Containers"
    And there is a custom text field "Model" in community "test" in category "Containers"
    And there is a custom text field "Container Size" in community "test" in category "Containers"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Containers" from listing type menu
    And I select "Selling" from listing type menu
    And I wait for 2 seconds
    Then the listing title field should have "" as a value

  @javascript
  Scenario: Container listing title is assigned automatically from the selected Manufacturer Model and Container Size
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Containers"
    And there is a custom text field "Model" in community "test" in category "Containers"
    And there is a custom text field "Container Size" in community "test" in category "Containers"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Containers" from listing type menu
    And I select "Selling" from listing type menu
    And I select "Mirage Systems" for the "Manufacturer" variable custom field
    And I select "Mirage G2" for the "Model" variable custom field
    And I select "MXS" for the "Container Size" variable custom field
    And I wait for 2 seconds
    Then the listing title field should have "Mirage G2 MXS" as a value

  @javascript
  Scenario: Container listing title is assigned automatically from the selected Manufacturer Model and Container Size are custom
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Containers"
    And there is a custom text field "Model" in community "test" in category "Containers"
    And there is a custom text field "Container Size" in community "test" in category "Containers"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Containers" from listing type menu
    And I select "Selling" from listing type menu
    And I select "Other" for the "Manufacturer" variable custom field
    And I wait for 2 seconds
    And I fill in custom text field "Manufacturer" with "My Manufacturer"
    And I fill in custom text field "Model" with "My Model"
    And I fill in custom text field "Container Size" with "My Size"
    And I remove the focus
    Then the listing title field should have "My Model My Size" as a value

  @javascript 
  Scenario: Main Canopy listing title is assigned automatically from selected Manufacturer, Model & Size
    Given I am logged in
    And I am on the home page
    And there is a custom text field "Manufacturer" in community "test" in category "Main"
    And there is a custom text field "Model" in community "test" in category "Main"
    And there is a custom text field "Size" in community "test" in category "Main"
    And I refresh custom field ids
    When I follow "new-listing-link"
    And I select "Canopies" from listing type menu
    And I select "Main" from listing type menu
    And I select "Selling" from listing type menu
    And I select "Aerodyne" for the "Manufacturer" variable custom field
    And I select "Pilot7" for the "Model" variable custom field
    And I select "147" for the "Size" variable custom field
    Then the listing title field should have "Pilot7 147" as a value