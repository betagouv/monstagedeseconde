module Events
  class EduconnectFailureSubscriber
    def emit(event)
      tags = extract_hash(event, :tags)
      return unless tags[:educonnect_failure].present?

      EventReport.create_from_educonnect_failure(
        event_payload(event).merge(
          event_name: event_name(event),
          tag: "educonnect_failure"
        )
      )
    rescue StandardError => e
      Rails.logger.error("EduconnectFailureSubscriber error: #{e.message}")
      Rails.logger.error("Backtrace:\n#{e.backtrace.join("\n")}")
    end

    private

    def event_name(event)
      event.try(:name) || extract_hash(event)[:name]
    end

    def event_payload(event)
      payload = event.try(:payload) || extract_hash(event, :payload)
      payload.is_a?(Hash) ? payload : {}
    end

    def extract_hash(event, key = nil)
      hash = event.respond_to?(:to_h) ? event.to_h : {}
      hash = hash.deep_symbolize_keys
      return hash if key.nil?

      value = hash[key]
      value.is_a?(Hash) ? value.deep_symbolize_keys : {}
    end
  end
end
