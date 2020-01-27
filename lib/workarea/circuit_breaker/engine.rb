module Workarea
  module CircuitBreaker
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::CircuitBreaker

      config.after_initialize do
        Workarea::CircuitBreaker.freeze_config!
      end
    end
  end
end
