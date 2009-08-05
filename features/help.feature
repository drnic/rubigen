Feature: Generators offer help/usage details
  In order to reduce cost of learning about a new generator
  As a generator user
  I want help/usage details about generators
  
  Scenario: List of visible generators for rubygems
    When I run local executable "rubigen rubygems" with arguments ""
    Then I should see "application_generator"
    Then I should see "component_generator"
    Then I should not see "migration" # from rails scope
  

  
