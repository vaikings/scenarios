# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scenarios/version'

Gem::Specification.new do |spec|
  spec.name          = "scenario_server"
  spec.version       = Scenarios::VERSION
  spec.authors       = ["Vaibhav Bhatia"]
  spec.email         = ["vaikings@gmail.com"]
  spec.summary       = %q{Scenarios is a sinatra server which returns mock json fixtures for routes in the current scenario}
  spec.description   = %q{This gem is useful for development where a mock rest api server is required and with frank UI test automation.}
  spec.homepage      = 'https://bitbucket.org/vaikings/scenarios'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sinatra", "~> 1.4"
  spec.add_runtime_dependency "sinatra-contrib", "~> 1.4"
  spec.add_runtime_dependency "sequel", "4.7"
  spec.add_runtime_dependency "sqlite3" , "~> 1.3"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "rspec", "~> 2.0"
  spec.add_development_dependency "json_spec", "~> 1.1"
  
end
