require File.dirname(__FILE__) + "/test_helper"

class TestGenerateBuiltinApplication < Test::Unit::TestCase

  def setup
    bare_setup
  end
  
  def teardown
    bare_teardown
  end
  
  def test_ruby_app
    app_name = "myapp"
    run_generator('ruby_app', ["#{APP_ROOT}/#{app_name}"], :app)
    assert_generated_file("#{app_name}/Rakefile")
    assert_generated_file("#{app_name}/README.txt")
    assert_generated_file("#{app_name}/lib/#{app_name}.rb")
    assert_generated_file("#{app_name}/test/test_helper.rb")
    assert_generated_file("#{app_name}/script/generate")
    
    assert_generated_module("#{app_name}/lib/#{app_name}")
  end
end