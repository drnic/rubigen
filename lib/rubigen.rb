$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require 'active_support' 
rescue LoadError
  require 'rubygems'
  gem 'activesupport'
  require 'active_support' 
end

module RubiGen
  VERSION = '1.3.4'
end

require 'rubigen/base'
require 'rubigen/lookup'
require 'rubigen/commands'

RubiGen::Base.send(:include, RubiGen::Lookup)
RubiGen::Base.send(:include, RubiGen::Commands)

# Set up a default logger for convenience.
require 'rubigen/simple_logger'
RubiGen::Base.logger = RubiGen::SimpleLogger.new(STDOUT)

