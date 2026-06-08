class EventReport < ApplicationRecord
  # event_name character varying,
  # stage character varying,
  # severity integer,
  # student_ine character varying,
  # json_payload jsonb,
  # code_line character varying,
  # tag character varying,
  # created_at timestamp(6) without time zone NOT NULL,
  # updated_at timestamp(6) without time zone NOT NULL,
  #
  validates_presence_of :event_name,
                        :severity,
                        :code_line,
                        :json_payload,
                        :tag

  EDUCONNECT_EVENT_NAME = "educonnect.failure".freeze
  EDUCONNECT_TAG = "educonnect_failure".freeze
  DEFAULT_SEVERITY = 3

  class << self
    def create_from_educonnect_failure(payload)
      normalized_payload = normalize_payload(payload)

      create!(
        event_name: normalized_payload[:event_name],
        stage: normalized_payload[:stage],
        severity: normalized_payload[:severity],
        student_ine: normalized_payload[:student_ine],
        json_payload: normalized_payload[:json_payload],
        code_line: normalized_payload[:code_line],
        tag: normalized_payload[:tag]
      )
    end

    private

    def normalize_payload(payload)
      payload = payload.to_h.deep_symbolize_keys
      context = sanitize_context(payload[:context])

      {
        event_name: payload[:event_name].presence || EDUCONNECT_EVENT_NAME,
        stage: payload[:stage],
        severity: payload[:severity].presence || DEFAULT_SEVERITY,
        student_ine: payload[:student_ine],
        code_line: payload[:code_line].presence || "n/a",
        tag: payload[:tag].presence || EDUCONNECT_TAG,
        json_payload: {
          error_class: payload[:error_class],
          message: payload[:message],
          request_id: payload[:request_id],
          school_uai: payload[:school_uai],
          response_code: payload[:response_code],
          context: context
        }.compact
      }
    end

    def sanitize_context(context)
      return {} unless context.is_a?(Hash)

      context.deep_symbolize_keys.except(
        :access_token,
        :authorization,
        :id_token,
        :refresh_token,
        :token
      )
    end
  end
end
