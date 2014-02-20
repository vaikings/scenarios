# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scenarios/version'

Gem::Specification.new do |spec|
  spec.name          = "scenarios"
  spec.version       = Scenarios::VERSION
  spec.authors       = ["Vaibhav Bhatia"]
  spec.email         = ["vaikings@gmail.com"]
  spec.summary       = %q{Scenarios is a sinatra server which vends json fixtures for predefined routes}
  spec.description   = %q{This gem is useful for development and with frank test automation.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "sinatra-contrib"
  spec.add_runtime_dependency "sequel"

  spec.add_development_dependency "sequel" 
  spec.add_development_dependency "sqlite3" 
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "json_spec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"
  
end
