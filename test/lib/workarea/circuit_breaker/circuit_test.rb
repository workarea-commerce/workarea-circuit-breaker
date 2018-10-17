require 'test_helper'

module Workarea
  module CircuitBreaker
    class CircuitTest < Workarea::TestCase
      include CircuitBreakerSupport

      def test_healthy?
        assert(circuit.healthy?)
      end

      def test_healthy_with_redis_pool_timeout
        with_connection_pool_timeouts do
          assert(circuit.healthy?)
        end
      end

      def test_set_healthy
        3.times { circuit.add_failure message: "failed!" }
        refute(circuit.healthy?)

        circuit.set_healthy!
        assert(circuit.healthy?)
        assert_equal([], CircuitBreaker.redis.with do |redis|
          redis.zrange circuit.redis_failure_set_key, 0, -1
        end)
      end

      def test_set_healthy_with_redis_pool_timeout
        assert_nothing_raised do
          with_connection_pool_timeouts do
            circuit.set_healthy!
          end
        end
      end

      def test_break!
        circuit.break!
        refute(circuit.healthy?)
      end

      def test_add_failure
        assert_equal(1, circuit.add_failure(message: "Failure"))
        assert(circuit.healthy?)
        assert_equal(2, circuit.add_failure(message: "Failure"))
        assert(circuit.healthy?)
        assert_equal(3, circuit.add_failure(message: "Failure"))
        refute(circuit.healthy?)
      end

      def test_break_with_redis_pool_timeout
        assert_nothing_raised do
          with_connection_pool_timeouts do
            circuit.break!
          end
        end
      end

      def test_wrap_healthy_without_fallback
        response = circuit.wrap do
          "healthy response"
        end

        assert_equal("healthy response", response)
      end

      def test_wrap_failing_without_fallback
        error = assert_raises do
          circuit.wrap do
            raise 'http timeout'
          end
        end

        assert_equal('http timeout', error.message)
      end

      def test_wrap_failing_with_fallback_with_symbol
        response = circuit.wrap(fallback: :local_data) do
          raise "http timeout"
        end

        assert_equal("fallback response", response)
      end

      def test_wrap_failing_with_callable_fallback
        fallback = -> { "callable fallback" }

        response = circuit.wrap(fallback: fallback) do
          raise "http timeout"
        end

        assert_equal("callable fallback", response)
      end

      def test_wrap_when_broken_without_fallback
        circuit.break!

        assert_raises CircuitBreakerError do
          circuit.wrap do
            raise "never used"
          end
        end
      end

      def test_wrap_when_broken_with_fallback
        circuit.break!

        response = circuit.wrap(fallback: :local_data) do
          raise "http timeout"
        end

        assert_equal("fallback response", response)
      end

      def test_wrap_breaks_circuit
        circuit.wrap(fallback: :local_data) { raise "http timeout" }
        assert(circuit.healthy?)
        circuit.wrap(fallback: :local_data) { raise "http timeout" }
        assert(circuit.healthy?)
        circuit.wrap(fallback: :local_data) { raise "http timeout" }
        refute(circuit.healthy?)
      end

      private

        def circuit
          @circuit ||= Circuit.new(:fake_service, { max_fails: 3 })
        end

        def local_data
          "fallback response"
        end
    end
  end
end
