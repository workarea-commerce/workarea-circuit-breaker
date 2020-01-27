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

    # Capture errors thrown by code that is running in the circuit
    # breaker. When `Sentry::Raven` is installed, send the error over to
    # Sentry and return the event ID. Otherwise, just return `nil`. This
    # will also return `nil` when Sentry is not configured to capture
    # exceptions in the environment, such as when tests are running.
    #
    # @param [Exception] exception - Error thrown by the application
    # @return [String] Event ID or `nil` when the exception was not
    #                  captured by Sentry.
    def self.capture_exception(exception)
      event = if defined?(::Raven)
        Raven.capture_exception(exception) || nil
      else
        Rails.logger.warn exception
        nil
      end

      return if event.blank?

      event.id
    end

    def self.freeze_config!
      Workarea.config.circuit_breaker.freeze
      Workarea.config.circuit_breaker.circuits.freeze
      Workarea.config.circuit_breaker.circuit_defaults.freeze
    end

    private

      def self.pool_options
        config.redis.fetch(:pool, {})
      end
  end
end
