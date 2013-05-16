# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'muggy/version'

Gem::Specification.new do |gem|
  gem.name          = "muggy"
  gem.version       = Muggy::VERSION
  gem.authors       = ["Lachie Cox"]
  gem.email         = ["lachiec@gmail.com"]
  gem.description   = %q{Amazonian Fog - Convenient way of working with just AWS and fog.}
  gem.summary       = %q{We use fog mostly with amazon. This makes it a bit more convenient.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'fog'
  gem.add_dependency 'aws-sdk'
end
