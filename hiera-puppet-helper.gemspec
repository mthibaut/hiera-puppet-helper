# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hiera-puppet-helper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Maarten Thibaut"]
  gem.email         = ["mthibaut@cisco.com"]
  gem.description   = %q{Hiera fixtures for rspec-puppet tests.}
  gem.summary       = %q{Hiera fixtures for rspec-puppet tests.}
  gem.homepage      = "https://github.com/mthibaut/hiera-puppet-helper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hiera-puppet-helper"
  gem.require_paths = ["lib"]
  gem.version       = HieraPuppetHelper::VERSION
end
