# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rubigen/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dr Nic Williams", 'Jeremy Kemper', 'Ben Klang']
  gem.email         = ["drnicwilliams@gmail.com"]
  gem.description   = %q{RubiGen - Ruby Generator Framework}
  gem.summary       = <<-EOS.gsub(/^\s{2}/, '')
  A framework to allow Ruby applications to generate file/folder stubs 
  (like the `rails` command does for Ruby on Rails, and the 'script/generate'
  command within a Rails application during development).
  EOS
  gem.homepage      = "http://drnic.github.com/rubigen"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rubigen"
  gem.require_paths = ["lib"]
  gem.version       = Rubigen::VERSION
  
  gem.add_dependency 'activesupport', '>= 2.3.5', "< 3.2.0"
  gem.add_dependency 'i18n'
  gem.add_dependency 'mocha','>= 0.9.8'
  gem.add_dependency 'launchy'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec','~>1.3'
  gem.add_development_dependency 'cucumber','>= 0.6.2'
  gem.add_development_dependency 'shoulda','>= 2.10.3'
end
