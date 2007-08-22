require 'test/unit'
require File.dirname(__FILE__) + '/../lib/rubigen'
require 'rubigen/helpers/generator_test_helper'
include RubiGen

begin
  gem 'mocha'
rescue LoadError
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
end
require 'mocha'