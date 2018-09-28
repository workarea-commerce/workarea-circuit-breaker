module Workarea
  module CircuitBreaker
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::CircuitBreaker
    end
  end
end
