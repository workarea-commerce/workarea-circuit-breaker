require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::CircuitBreaker::Engine.root
  Workarea::Teaspoon.apply(config)
end
