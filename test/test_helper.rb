require 'test/unit'
require File.dirname(__FILE__) + '/../lib/rubigen'
require 'rubigen/helpers/generator_test_helper'
include RubiGen

begin
  require 'mocha'
rescue LoadError
  require 'rubygems'
  gem 'mocha'
  require 'mocha'
end
