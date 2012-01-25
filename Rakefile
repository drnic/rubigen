require 'rubygems'
require 'hoe'
require './lib/rubigen'

Hoe.plugin :newgem
Hoe.plugin :website
Hoe.plugin :cucumberfeatures
Hoe.plugin :git

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
Hoe.spec 'rubigen' do
  developer 'Dr Nic Williams', 'drnicwilliams@gmail.com'
  developer 'Jeremy Kemper', 'jeremy@bitsweat.net'
  developer 'Ben Klang', 'bklang@mojolingo.com'
  extra_deps << ['activesupport','>= 2.3.5', "< 3.2.0"]
  # Needed when loading active_support/all
  extra_deps << ['i18n']
  extra_dev_deps << ['rspec','~>1.3']
  extra_dev_deps << ['mocha','>= 0.9.8']
  extra_dev_deps << ['cucumber','>= 0.6.2']
  extra_dev_deps << ['shoulda','>= 2.10.3']
  extra_dev_deps << ['hoe']
  extra_dev_deps << ['hoe-git']
  extra_dev_deps << ['newgem']
end

require 'newgem/tasks' rescue nil # load /tasks/*.rake

task :default => :features
