module Workarea
  module CircuitBreaker
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::CircuitBreaker

      config.after_initialize do
        Workarea.config.circuit_breaker.freeze
        Workarea.config.circuit_breaker.circuits.freeze
        Workarea.config.circuit_breaker.circuit_defaults.freeze
      end
    end
  end
end
