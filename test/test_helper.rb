require 'test/unit'
require File.dirname(__FILE__) + '/../lib/rubigen'
require 'rubigen/helpers/generator_test_helper'
include RubiGen

def load_mocha
  require 'rubygems'
  begin
    gem 'mocha'
  rescue LoadError
    puts <<-EOS
#{$!}

This RubyGem is required to run the tests.

Install: gem install mocha    
EOS
  end
  require 'mocha'
end
begin
  gem 'mocha'
rescue LoadError
  load_mocha
rescue NoMethodError
  load_mocha
end

require "shoulda"