module Workarea
  module Admin
    class CircuitsController < Admin::ApplicationController
      def index
        @circuits = Admin::CircuitsViewModel.new
      end

      def disable
        circuit = CircuitViewModel.new(CircuitBreaker[params[:id]])
        circuit.add_failure(message: t('workarea.admin.circuit_breaker.manually_broke_circuit', user: current_user.name))
        circuit.break!

        flash[:success] = t('workarea.admin.circuit_breaker.flash_messages.turned_off', circuit: circuit.name, break_for: circuit.break_for.inspect)
        redirect_to circuits_path
      end

      def enable
        circuit = CircuitViewModel.new(CircuitBreaker[params[:id]])
        circuit.set_healthy!

        flash[:success] = t('workarea.admin.circuit_breaker.flash_messages.turned_on', circuit: circuit.name)
        redirect_to circuits_path
      end
    end
  end
end
