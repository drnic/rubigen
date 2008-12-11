require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

class TestGenerateBuiltinApplication < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    bare_setup
  end
  
  def teardown
    bare_teardown
  end
  
  def test_ruby_app
    run_generator('ruby_app', [APP_ROOT], sources)
    assert_generated_file("Rakefile")
    assert_generated_file("README.txt")
    assert_generated_file("lib/#{PROJECT_NAME}.rb")
    assert_generated_file("test/test_helper.rb")
    assert_generated_file("script/generate")
    assert_generated_file("script/destroy")
    
    assert_generated_module("lib/#{PROJECT_NAME}")
  end

  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path)),
     RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", "generators"))
    ]
  end
  
  def generator_path
    "app_generators"
  end
end