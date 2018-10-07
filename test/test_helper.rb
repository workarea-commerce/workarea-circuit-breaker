require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'lib/workarea/circuit_breaker/version.rb'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
require 'rails/test_help'
require 'workarea/test_help'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
