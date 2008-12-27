Feature: Generators offer help/usage details
  In order to reduce cost of learning about a new generator
  As a generator user
  I want help/usage details about generators
  
  Scenario: List of visible generators for rubygems
    Given a safe folder
    When run local executable 'rubigen rubygems' with arguments ''
    Then output does match /application_generator/
    And output does match /component_generator/
    And output does not match /migration/ # from rails scope
  

  
