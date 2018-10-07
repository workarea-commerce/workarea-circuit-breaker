module Workarea
  module CircuitBreaker
    class Circuit
      attr_reader :name, :options

      def initialize(name, **options)
        @name = name.to_s
        @options = CircuitBreaker.circuit_defaults.merge(options).symbolize_keys
      end

      # Checks if this circuit is currently, defaults to true
      #
      # @return [Boolean]
      def healthy?
        broken = CircuitBreaker.redis.with do |connection|
          connection.get(redis_broken_key)
        end

        broken.nil?
      rescue Timeout::Error => error
        CircuitBreaker.capture_exception(error)
        true
      end

      # Set the circuit to be healthy
      #
      # @return [nil]
      def set_healthy!
        CircuitBreaker.redis.with do |connection|
          connection.pipelined do
            connection.del(redis_broken_key)
            connection.del(redis_failure_set_key)
          end
        end
        nil
      rescue Timeout::Error => error
        CircuitBreaker.capture_exception(error)
        nil
      end

      # Break this circuit for the configured break_for duration of this service
      #
      # @return nil
      def break!
        CircuitBreaker.redis.with do |connection|
          connection.setex(redis_broken_key, break_for, break_for.from_now.to_i)
        end
        nil
      rescue Timeout::Error => error
        CircuitBreaker.capture_exception(error)
        nil
      end

      # Wraps the black around a circuit.  If the circuit is healthy the block
      # is executed and it's return value is returned.  If the black raises an error
      # an event is added to the circuit timeline.  If a fallback is provided the
      # fallback is invoked otherwise an error is raised
      #
      # @param [Symbol, Object] either a symbol of a method defined on the blocks binding receiver or anything that responds to call
      def wrap(fallback: nil, &block)
        if healthy?
          begin
            block.call
          rescue => error
            event_id = CircuitBreaker.capture_exception(error)
            add_failure(event_id: event_id, message: "#{error.class}: #{error.message}")
            fallback_or_error(block.binding.receiver, fallback: fallback, error: error)
          end
        else
          fallback_or_error(block.binding.receiver, fallback: fallback, error: CircuitBreakerError)
        end
      end

      def window
        options[:window]
      end

      def break_for
        options[:break_for]
      end

      def max_fails
        options[:max_fails]
      end

      # @param [String] event_id Raven::Event#id
      # @param [String] message - normally an error message
      #
      # @return [Int] number of events in the timeline
      def add_failure(message:, event_id: nil)
        CircuitBreaker.redis.with do |connection|
          failure_message = FailureMessage.new(event_id: event_id, message: message)

          _deleted, _added, length, _expiry_set = connection.pipelined do
            connection.zremrangebyscore(redis_failure_set_key, 0, break_for.ago.to_i)
            connection.zadd(redis_failure_set_key, Time.current.to_i, failure_message.to_s)
            connection.zcard(redis_failure_set_key)
            # expire as the time a circuit could be broken so info is avaiable whole length
            # of broken time
            connection.expire(redis_failure_set_key, break_for.to_i)
          end

          break! if length >= max_fails

          length
        end
      rescue Timeout::Error => error
        CircuitBreaker.capture_exception(error)
        0
      end

      def redis_broken_key
        "#{redis_key_base}:broken"
      end

      def redis_failure_set_key
        "#{redis_key_base}:failures"
      end

      private

        def fallback_or_error(receiver, fallback: nil, error: nil)
          if fallback.blank?
            raise error
          elsif fallback.respond_to?(:call)
            fallback.call
          elsif receiver.respond_to?(fallback, true)
            receiver.send(fallback)
          end
        end

        def redis_key_base
          "#{CircuitBreaker::CIRCUIT_KEY_BASE}:#{name.to_s.systemize}"
        end
    end
  end
end
