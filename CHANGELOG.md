Workarea Circuit Breaker 1.0.3 (2020-02-05)
--------------------------------------------------------------------------------

*   Remove SENTRY_DSN from workflow

    Tom Scott

*   Fix Exception Capturing

    Since `Raven.capture_exception` can sometimes return a blank value,
    ensure that `CircuitBreaker.capture_exception` won't throw an error when
    trying to get the event ID from Sentry. Fixes a test that breaks when
    both the Sentry and CircuitBreaker plugins are installed.

    WORKAREA-189
    Tom Scott



Workarea Circuit Breaker 1.0.2 (2019-08-06)
--------------------------------------------------------------------------------

*   Only run config freezing test when running tests from source

    WCB-3
    Jeff Yucis



Workarea Circuit Breaker 1.0.1 (2019-04-30)
--------------------------------------------------------------------------------

*   Improve admin UI

    Add tool tips to the circuit breaker table along with help text. Fix a bug with user name not displaying in the time line message. Add link to settings menu.

    WCB-2
    Eric Pigeon



Workarea Circuit Breaker 1.0.0 (2018-11-13)
--------------------------------------------------------------------------------

*   Workarea Circuit Breaker

    Circuit Breaker is small libray that allows you to wrap calls to
    external services and provide safe fallbacks during external outages.

    WCB-1
    Eric Pigeon



