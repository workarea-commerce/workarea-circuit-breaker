$:.push File.expand_path("lib", __dir__)

require "workarea/circuit_breaker/version"

Gem::Specification.new do |s|
  s.name        = "workarea-circuit_breaker"
  s.version     = Workarea::CircuitBreaker::VERSION
  s.authors     = ["Eric Pigeon"]
  s.email       = ["epigeon@weblinc.com"]
  s.summary     = "Circuit breaker library for Workarea"
  s.description = "Small libray to implement circuit breaker design pattern around external service calls"

  s.files = `git ls-files`.split("\n")

  s.add_dependency 'workarea', '~> 3.x'
  s.add_dependency 'connection_pool', '~> 2.2', '>= 2.2.2'
end
