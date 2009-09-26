require File.dirname(__FILE__) + '/test_helper'
require 'fileutils'

# Must set before requiring generator libs.
TMP_ROOT = File.expand_path(File.dirname(__FILE__) + "/../tmp") unless defined?(TMP_ROOT)
PROJECT_NAME = "myproject" unless defined?(PROJECT_NAME)
app_root = File.join(TMP_ROOT, PROJECT_NAME)
if defined?(APP_ROOT)
  APP_ROOT.replace(app_root)
else
  APP_ROOT = app_root
end

FileUtils.mkdir_p(APP_ROOT)

require 'rubigen/helpers/generator_test_helper'

FileUtils.rm_rf(File.dirname(__FILE__) + "/tmp") # seem to be issues on runcoderun with a test/tmp/... folder still