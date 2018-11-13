Workarea Circuit Breaker
================================================================================

Circuit Breaker plugin for the Workarea platform.

## Configuration

Configure how circuit breaker should handle external service calls

    # window: the window of time to count failed calls to break the circuit
    # max_fails: how many failed calls need to happen in the window to break the circuit
    # break_for: how long the circuit should fast fail after broken
    Workarea.Configure do |config|
      config.circuit_breaker.circuits = {
        exteral_service: { max_fails: 3, break_for: 5.minutes, window: 5.minutes }
      }
    end

or use `CircuitBreaker.add_service`

    # configure service with circuit defaults
    CircuitBreaker.add_service(:external_service)

## Usage

    # will re-raise any errors raised in the block or
    #raise ::Workarea::CircuitBreaker::CircuitBreakerError if the circuit is broken
    Workarea::CircuitBreaker[:service].wrap do
      Net::HTTP.get_response(.....)
    end

Wrap takes a parameter `fallback` which is either a symbol of a method defined in
the current scope to call when the circuit is broken or an error is raised in the block
or anything that responds to #call

Using a symbol

    Workarea::CircuitBreaker[:service].wrap(fallback: :faked_response) do
      Net::HTTP.get_response(.....)
    end

    private

    def faked_response
      "...."
    end

Using a lambda

    fallback = -> { "..." }
    Workarea::CircuitBreaker[:service].wrap(fallback: fallback) do
      Net::HTTP.get_response(.....)
    end

## Admin

An admin to view circuits is available at `/admin/circuits`, only viewable by
`super_admin`s.  Circuit status can viewed and can be manually broken or reset.

Getting Started
--------------------------------------------------------------------------------

This gem contains a rails engine that must be mounted onto a host Rails application.

To access Workarea gems and source code, you must be an employee of WebLinc or a licensed retailer or partner.

Workarea gems are hosted privately at https://gems.weblinc.com/.
You must have individual or team credentials to install gems from this server. Add your gems server credentials to Bundler:

    bundle config gems.weblinc.com my_username:my_password

Or set the appropriate environment variable in a shell startup file:

    export BUNDLE_GEMS__WEBLINC__COM='my_username:my_password'

Then add the gem to your application's Gemfile specifying the source:

    # ...
    gem 'workarea-circuit_breaker', source: 'https://gems.weblinc.com'
    # ...

Or use a source block:

    # ...
    source 'https://gems.weblinc.com' do
      gem 'workarea-circuit_breaker'
    end
    # ...

Update your application's bundle.

    cd path/to/application
    bundle

Workarea Platform Documentation
--------------------------------------------------------------------------------

See [http://developer.weblinc.com](http://developer.weblinc.com) for Workarea platform documentation.

Copyright & Licensing
--------------------------------------------------------------------------------

Copyright WebLinc 2018. All rights reserved.

For licensing, contact sales@workarea.com.
