module Workarea
  module Admin
    class CircuitsViewModel < ApplicationViewModel
      delegate :each, to: :all

      private

        def all
          @all ||= circuits.zip(circuits_broken_until, circuits_timeline).map do |circuit, broken_until, timeline|
            CircuitViewModel.new(
              circuit,
              broken_until: broken_until,
              timeline: timeline
            )
          end
        end

        def circuits
          @circuits ||= CircuitBreaker.config.circuits.map do |name, options|
            CircuitBreaker::Circuit.new(name, options)
          end
        end

        def circuits_timeline
          @circuits_timeline ||= CircuitBreaker.redis.with do |redis|
            redis.pipelined do
              circuits.each do |circuit|
                redis.zrange(circuit.redis_failure_set_key, 0, -1, with_scores: true)
              end
            end
          end
        end

        def circuits_broken_until
          @circuits_broken_until ||= CircuitBreaker.redis.with do |redis|
            redis.mget(circuits.map(&:redis_broken_key))
          end
        end
    end
  end
end
