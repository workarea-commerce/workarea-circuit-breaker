require 'test_helper'

module Workarea
  class CircuitBreakerTest < Workarea::TestCase
    def test_add_service
      Workarea.with_config do |config|
        CircuitBreaker.add_service(:fake_service)

        assert(config.circuit_breaker.circuits.has_key?("fake_service"))
      end
    end

    def test_brackets
      Workarea.with_config do |_config|
        options = { max_fails: 3, window: 5.minutes, break_for: 5.minutes }
        CircuitBreaker.add_service(:fake_service, **options)

        circuit = CircuitBreaker[:fake_service]

        assert_equal("fake_service", circuit.name)
        assert_equal(options, circuit.options)
      end
    end

    if running_from_source?
      def test_config_is_frozen
        Workarea::CircuitBreaker.freeze_config!

        assert Workarea.config.circuit_breaker.frozen?
        assert Workarea.config.circuit_breaker.circuits.frozen?
        assert Workarea.config.circuit_breaker.circuit_defaults.frozen?
      end
    end
  end
end
