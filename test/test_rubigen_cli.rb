require File.join(File.dirname(__FILE__), "test_helper.rb")
require 'rubigen/cli'

class TestRubigenCli < Test::Unit::TestCase
  attr_reader :stdout
  
  context "run executable with scope 'rubygems'" do
    setup do
      Rubigen::CLI.execute(@stdout_io = StringIO.new, %w[rubygems])
      @stdout_io.rewind
      @stdout = @stdout_io.read
    end

    should "display help" do
      assert_match(/General Options/, stdout)
    end
    
    should "display installed generators for 'rubygems'" do
      assert_match(/Installed Generators/, stdout)
      assert_match(/application_generator/, stdout)
      assert_match(/component_generator/, stdout)
    end
  end
  
  context "run executable without any arguments" do
    setup do
      Rubigen::CLI.execute(@stdout_io = StringIO.new, %w[])
      @stdout_io.rewind
      @stdout = @stdout_io.read
    end

    should "display main usage" do
      assert_match(/Usage:/, stdout)
    end
  end
  
end