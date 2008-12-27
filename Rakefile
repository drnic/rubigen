%w[rubygems rake rake/clean newgem].each { |f| require f }
require File.dirname(__FILE__) + '/lib/rubigen'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('rubigen', RubiGen::VERSION) do |p|
  p.developer('Dr Nic Williams', 'drnicwilliams@gmail.com')
  p.developer('Jeremy Kemper', 'jeremy@bitsweat.net')
  p.changes        = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.extra_deps     = [['activesupport','>= 2.2.2']]
  p.extra_dev_deps = [['newgem', ">= #{::Newgem::VERSION}"]]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake

task :default => :features
