# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rubigen/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dr Nic Williams", 'Jeremy Kemper', 'Ben Klang']
  gem.email         = ["drnicwilliams@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rubigen"
  gem.require_paths = ["lib"]
  gem.version       = Rubigen::VERSION
  
  gem.add_dependency 'activesupport', '>= 2.3.5', "< 3.2.0"
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'i18n'
  gem.add_development_dependency 'rspec','~>1.3'
  gem.add_development_dependency 'mocha','>= 0.9.8'
  gem.add_development_dependency 'cucumber','>= 0.6.2'
  gem.add_development_dependency 'shoulda','>= 2.10.3'
  gem.add_development_dependency 'launchy'
end
