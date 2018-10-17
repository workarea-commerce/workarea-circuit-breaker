module Workarea
  module Admin
    class CircuitViewModel < ApplicationViewModel
      def name
        model.name.to_s.humanize
      end

      def slug
        model.name
      end

      def current_fails
        timeline.length
      end

      def broken_until
        return unless options[:broken_until].present?

        Time.at(options[:broken_until].to_i)
      end

      def healthy?
        options[:broken_until].blank?
      end

      def timeline
        @timeline ||= options.fetch(:timeline, []).map do |(failure_string, timestamp)|
          CircuitBreaker::FailureMessage.from_string(failure_string, Time.at(timestamp))
        end
      end
    end
  end
end
