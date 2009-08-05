require "hoe"
require './lib/rubigen'

Hoe.plugin :newgem
Hoe.plugin :website
Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
Hoe.spec 'rubigen' do
  developer 'Dr Nic Williams', 'drnicwilliams@gmail.com'
  developer 'Jeremy Kemper', 'jeremy@bitsweat.net'
  extra_deps << ['activesupport','>= 2.2.2']
  extra_deps << ['mocha','>= 0.9.7']
  extra_deps << ['cucumber','>= 0.3.6']
  # extra_deps << ['thoughtbot-shoulda','>= 2.10.2']
end

require 'newgem/tasks' rescue nil # load /tasks/*.rake

task :default => :features
