require 'test/unit'

# Must set before requiring generator libs.
TMP_ROOT = File.dirname(__FILE__) + "/tmp" unless defined?(TMP_ROOT)
app_root = File.join(TMP_ROOT, "myproject")
if defined?(APP_ROOT)
  APP_ROOT.replace(app_root)
else
  APP_ROOT = app_root
end

require File.dirname(__FILE__) + '/../lib/rubigen'
require 'rubigen/helpers/generator_test_helper'
Test::Unit::TestCase.send(:include, RubiGen::GeneratorTestHelper)
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