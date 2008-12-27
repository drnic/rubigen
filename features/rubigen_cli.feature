Feature: rubigen command-line interface to access generators anywhere
  In order to reduce cost of using rubigen
  As a Ruby developer
  I want to execute generators anywhere without a script/generate helper script
  
  Scenario: Run a component generator
    Given a safe folder
    When run local executable 'rubigen' with arguments 'rubygems component_generator foo bar'
    Then file 'bar_generators/foo/foo_generator.rb' is created
  
