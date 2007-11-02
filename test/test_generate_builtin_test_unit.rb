require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

class TestGenerateBuiltinTestUnit < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    bare_teardown
  end
  
  def teardown
    bare_teardown
  end
  
  def test_with_no_options
    run_generator('test_unit', %w[AccountReceiver], sources)
    assert_generated_file("test/test_account_receiver.rb")
    assert_generated_class("test/test_account_receiver", "Test::Unit::TestCase") do
      assert_has_method("setup")
      assert_has_method("teardown")
      assert_has_method("test_truth")
    end
  end

  private
  def sources
    [RubiGen::PathSource.new(:testing, File.join(File.dirname(__FILE__),"..", generator_path))
    ]
  end
  
  def generator_path
    "test_unit_generators"
  end
end