require 'test_helper'

module Workarea
  module CircuitBreaker
    class FailureMessageTest < Workarea::TestCase
      def test_to_s_without_event_id
        failure_message = FailureMessage.new(message: "Test")
        assert_equal(13, failure_message.to_s.length)
        assert_equal("0", failure_message.to_s[8, 1])
        assert_equal("Test", failure_message.to_s[9, 4])
      end

      def test_to_s_with_event_id
        event_id = SecureRandom.uuid.delete("-")
        failure_message = FailureMessage.new(event_id: event_id, message: "Test")
        assert_equal(47, failure_message.to_s.length)
        assert_equal("1", failure_message.to_s[8, 1])
        assert_equal("20", failure_message.to_s[9, 2])
        assert_equal(event_id, failure_message.to_s[11, 32])
        assert_equal("Test", failure_message.to_s[43, 4])
      end

      def test_from_string_without_event_id
        string = "2d519d2e0Test"
        failure_message = FailureMessage.from_string(string, Time.current.to_i)

        assert_equal("2d519d2e", failure_message.id)
        assert_equal("Test", failure_message.message)
      end

      def test_from_string_with_event_id
        string = "6519a8c5120c5d015ec01924a50920efd19a23e555eTest"
        failure_message = FailureMessage.from_string(string, Time.current.to_i)

        assert_equal("6519a8c5", failure_message.id)
        assert_equal("c5d015ec01924a50920efd19a23e555e", failure_message.event_id)
        assert_equal("Test", failure_message.message)
      end
    end
  end
end
