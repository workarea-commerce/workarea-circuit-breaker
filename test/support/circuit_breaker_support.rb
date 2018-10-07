module Workarea
  module CircuitBreakerSupport
    def with_connection_pool_timeouts(&block)
      @_original_pool = CircuitBreaker.redis
      timeout_pool = ConnectionPool.new(timeout: 0, size: 0) do
        Redis.new(url: Workarea::Configuration::Redis.persistent.to_url)
      end
      CircuitBreaker.instance_variable_set(:@redis, timeout_pool)

      block.call

    ensure
      CircuitBreaker.instance_variable_set(:@redis, @_original_pool)
    end
  end
end
