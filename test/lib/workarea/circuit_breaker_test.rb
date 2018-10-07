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

    def test_config_is_frozen
      error = assert_raises RuntimeError do
        CircuitBreaker.add_service(:fake_service)
      end

      assert_equal("can't modify frozen Hash", error.message)

      error = assert_raises RuntimeError do
        Workarea.config.circuit_breaker.circuit_defaults = {}
      end

      assert_equal("can't modify frozen ActiveSupport::Configurable::Configuration", error.message)
    end
  end
end
