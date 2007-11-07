$:.unshift(File.dirname(__FILE__))

begin
  require 'active_support' 
rescue LoadError
  require 'rubygems'
  gem 'activesupport'
  require 'active_support' 
end

require 'rubigen/base'
require 'rubigen/lookup'
require 'rubigen/commands'

RubiGen::Base.send(:include, RubiGen::Lookup)
RubiGen::Base.send(:include, RubiGen::Commands)

# Set up a default logger for convenience.
require 'rubigen/simple_logger'
RubiGen::Base.logger = RubiGen::SimpleLogger.new(STDOUT)

