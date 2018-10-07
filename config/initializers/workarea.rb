Workarea.configure do |config|
  config.circuit_breaker = ActiveSupport::Configurable::Configuration.new

  config.circuit_breaker.circuits ||= {}
  config.circuit_breaker.redis ||= {}
  config.circuit_breaker.circuit_defaults ||= {
    max_fails: 3,
    window: 5.minutes,
    break_for: 5.minutes
  }
end
