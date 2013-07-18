require "bundler/gem_tasks"
require 'rake/testtask'

require './lib/rubigen'

  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
  end


namespace :cucumber do
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:wip, 'Run features that are being worked on') do |t|
    t.cucumber_opts = "--tags @wip"
  end
  Cucumber::Rake::Task.new(:ok, 'Run features that should be working') do |t|
    t.cucumber_opts = "--tags ~@wip"
  end
  task :all => [:ok, :wip]
end

desc "Go to TravisCI status page"
task :travis do
  require "launchy"
  Launchy.open("http://travis-ci.org/#!/drnic/rubigen")
end
desc 'Alias for cucumber:ok'
task :cucumber => 'cucumber:ok'

task :default => ["test", "cucumber"]
