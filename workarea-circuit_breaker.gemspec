$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "workarea/circuit_breaker/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "workarea-circuit_breaker"
  s.version     = Workarea::CircuitBreaker::VERSION
  s.authors     = ["Eric Pigeon"]
  s.email       = ["epigeon@weblinc.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CircuitBreaker."
  s.description = "TODO: Description of CircuitBreaker."
  
  s.files = `git ls-files`.split("\n")

  s.add_dependency 'workarea', '~> 3.x'
end
