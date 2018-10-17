require 'connection_pool'

require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

require 'workarea/circuit_breaker/engine'
require 'workarea/circuit_breaker/version'
require 'workarea/circuit_breaker/circuit'
require 'workarea/circuit_breaker/failure_message'

module Workarea
  module CircuitBreaker
    class CircuitBreakerError < RuntimeError; end
    module ConnectionPoolLike
      def with
        yield self
      end
    end

    unless ::Redis.instance_methods.include?(:with)
      ::Redis.include(ConnectionPoolLike)
    end

    CIRCUIT_KEY_BASE = "workarea_circuits"

    def self.config
      Workarea.config.circuit_breaker
    end

    def self.circuit_defaults
      config.circuit_defaults
    end

    def self.add_service(name, **options)
      options = options.symbolize_keys
      overwrite = options.delete(:overwrite) || false

      if !overwrite && config.circuits.has_key?(name)
        Rails.logger.warn "Overwriting existing service #{name} in CircuitBreaker"
      end

      config.circuits[name.to_s] = options
    end

    def self.[](circuit_name)
      circuit_name = circuit_name.to_s
      options = config.circuits[circuit_name] || {}
      Circuit.new(circuit_name, **options)
    end

    def self.redis
      @redis ||= if pool_options.present?
        ConnectionPool.new(pool_options) do
          Redis.new(url: Workarea::Configuration::Redis.persistent.to_url)
        end
      else
        Redis.new(url: Workarea::Configuration::Redis.persistent.to_url)
      end
    end

    def self.capture_exception(exception)
      event_id = if defined?(::Raven)
        Raven.capture_exception(exception)&.id
      else
        Rails.logger.warn exception
        nil
      end
      event_id
    end

    private

      def self.pool_options
        config.redis.fetch(:pool, {})
      end
  end
end