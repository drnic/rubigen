require File.dirname(__FILE__) + "/test_generator_helper"
require 'rubigen/cli'

class TestRubigenCli < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper
  attr_reader :stdout

  context "run executable with scope 'rubygems'" do
    setup do
      bare_setup
      Rubigen::CLI.new.execute(@stdout_io = StringIO.new, 
        %w[rubygems component_generator name scope], :backtrace => true)
      @stdout_io.rewind
      @stdout = @stdout_io.read
    end

    should "create main generator manifest" do
      assert_file_exists("scope_generators/name/name_generator.rb")
    end
  end
  
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

  context "run executable with multiple scopes 'rubygems' and 'something_else'" do
    setup do
      # rubigen rubygems,something_else a_generator
      Rubigen::CLI.execute(@stdout_io = StringIO.new, ['rubygems,something_else'])
      @stdout_io.rewind
      @stdout = @stdout_io.read
    end

    should "display help" do
      assert_match(/General Options/, stdout)
    end
    
    should "display installed generators for 'rubygems,something_else'" do
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