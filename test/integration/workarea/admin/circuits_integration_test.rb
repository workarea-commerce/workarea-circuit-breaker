require 'test_helper'

module Workarea
  module Admin
    class CircuitsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_turning_on_circuit
        post admin.enable_circuit_path(:fake_service)
        assert(CircuitBreaker[:fake_service].healthy?)
        assert_equal(
          I18n.t('workarea.admin.circuit_breaker.flash_messages.turned_on', circuit: "Fake service"),
          flash[:success]
        )
      end

      def test_turning_off_circuit
        post admin.disable_circuit_path(:fake_service)
        refute(CircuitBreaker[:fake_service].healthy?)
        assert_equal(
          I18n.t('workarea.admin.circuit_breaker.flash_messages.turned_off', circuit: "Fake service", break_for: "5 minutes"),
          flash[:success]
        )
      end
    end
  end
end
