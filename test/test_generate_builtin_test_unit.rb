require File.dirname(__FILE__) + "/test_helper"

class TestGenerateBuiltinTestUnit < Test::Unit::TestCase

  def setup
    rubygems_setup
  end
  
  def teardown
    rubygems_teardown
  end
  
  def test_with_no_options
    run_generator('test_unit', %w[AccountReceiver], :component)
    assert_generated_file("test/test_account_receiver.rb")
    assert_generated_class("test/test_account_receiver", "Test::Unit::TestCase") do
      assert_has_method("setup")
      assert_has_method("teardown")
      assert_has_method("test_truth")
    end
  end
end