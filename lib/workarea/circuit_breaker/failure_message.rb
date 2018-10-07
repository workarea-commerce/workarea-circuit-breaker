module Workarea
  module CircuitBreaker
    class FailureMessage
      attr_reader :id, :event_id, :message, :timestamp

      def self.from_string(string, timestamp)
        id = string[0, 8]
        has_event_id = string[8, 1]
        if has_event_id == "1"
          event_id_length = string[9, 2].to_i(16)
          event_id = string[11, event_id_length]
          message = string[11+event_id_length, string.length]
        else
          event_id = nil
          message = string[9, string.length]
        end

        new(id: id, event_id: event_id, message: message, timestamp: timestamp)
      end

      # @param [String] id - Unique id only pass in .from_string
      # @param [String] event_id - A Raven::Event#id dropped if longer than 255
      # @param [String] message - Message stored in the set, normally an error message
      # @param [Time] timestamp - time of failure message only pass in .from_string
      def initialize(id: nil, event_id: nil, message: nil, timestamp: nil)
        @id = id || SecureRandom.hex(4)
        if event_id.present? && event_id.length < 256
          @event_id = event_id
        end
        @message = message
        @timestamp = timestamp
      end

      def to_s
        @to_s ||=
          begin
            s = id
            if event_id.present?
              s << "1"
              s << event_id.length.to_s(16)
              s << event_id
            else
              s << "0"
            end
            s << message
            s
          end
      end
    end
  end
end
