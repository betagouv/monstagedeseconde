# frozen_string_literal: true

require 'rack/utils'

module Api
  module JsonApiRenderable
    extend ActiveSupport::Concern

    private

    def render_jsonapi_collection(type:, records:, status: :ok, meta: nil, links: nil)
      data = Array(records).map { |record| jsonapi_resource_from(record, type:) }
      render json: compose_jsonapi_payload(data:, meta:, links:), status: status
    end

    def render_jsonapi_resource(type:, record:, status: :ok, meta: nil, links: nil)
      data = jsonapi_resource_from(record, type:)
      render json: compose_jsonapi_payload(data:, meta:, links:), status: status
    end

    def render_jsonapi_error(code:, detail:, status:, pointer: nil, meta: nil, title: nil)
      render_jsonapi_errors(
        [{
          code: code,
          detail: detail,
          status: status,
          pointer: pointer,
          meta: meta,
          title: title
        }],
        status:
      )
    end

    def render_jsonapi_errors(errors, status:)
      normalized_errors = Array(errors).map do |error|
        normalize_jsonapi_error(error, default_status: status)
      end

      render json: { errors: normalized_errors }, status: status
    end

    def render_error(code:, error:, status:)
      render_jsonapi_error(code:, detail: error, status:)
    end

    def render_bad_request
      render_jsonapi_error(code: 'BAD_REQUEST',
                           detail: 'bad request',
                           status: :bad_request)
    end

    def render_duplicate(duplicate_ar_object)
      render_jsonapi_error(
        code: "DUPLICATE_#{capitalize_class_name(duplicate_ar_object)}",
        detail: "#{underscore_class_name(duplicate_ar_object)} with this remote_id (#{duplicate_ar_object.remote_id}) already exists",
        status: :conflict
      )
    end

    def render_validation_error(invalid_ar_object)
      errors = invalid_ar_object.errors.map do |error|
        attribute, message, detail =
          if error.respond_to?(:full_message)
            [
              error.attribute,
              error.message,
              error.full_message
            ]
          else
            attribute, raw_message = Array(error).flatten
            attribute ||= :base
            message = Array(raw_message).compact.first.to_s
            friendly_attribute = attribute == :base ? nil : attribute.to_s.humanize
            [
              attribute,
              message,
              friendly_attribute.present? ? "#{friendly_attribute} #{message}" : message
            ]
          end

        {
          code: 'VALIDATION_ERROR',
          detail: detail.to_s,
          pointer: attribute && attribute != :base ? "/data/attributes/#{attribute}" : nil,
          status: :unprocessable_entity
        }.compact
      end

      render_jsonapi_errors(errors, status: :unprocessable_entity)
    end

    def render_discard_error(discard_ar_object)
      render_jsonapi_error(
        code: "#{capitalize_class_name(discard_ar_object)}_ALREADY_DESTROYED",
        detail: "#{underscore_class_name(discard_ar_object)} already destroyed",
        status: :conflict
      )
    end

    def render_argument_error(error)
      render_jsonapi_error(code: 'BAD_ARGUMENT',
                           detail: error.to_s,
                           status: :unprocessable_entity)
    end

    def render_not_authorized
      render_jsonapi_error(code: 'UNAUTHORIZED',
                           detail: 'access denied',
                           status: :unauthorized)
    end

    def compose_jsonapi_payload(data:, meta:, links:)
      payload = { data: data }
      payload[:meta] = meta if meta.present?
      payload[:links] = links if links.present?
      payload
      data
    end

    def jsonapi_resource_from(record, type:)
      source_hash =
        if record.respond_to?(:serializable_hash)
          record.serializable_hash
        elsif record.respond_to?(:to_h)
          record.to_h
        else
          record
        end

      resource_hash = source_hash.respond_to?(:deep_dup) ? source_hash.deep_dup : source_hash.dup
      resource_hash = resource_hash.deep_symbolize_keys
      id = resource_hash.delete(:id) { record.try(:id) }

      relationships = resource_hash.delete(:relationships)

      {
        type: type,
        id: id&.to_s,
        attributes: resource_hash
      }.tap do |resource|
        resource[:relationships] = relationships if relationships.present?
      end
    end

    def normalize_jsonapi_error(error, default_status:)
      return normalize_error_hash(error, default_status:) if error.is_a?(Hash)

      {
        status: status_to_string(default_status),
        detail: error.to_s
      }
    end

    def normalize_error_hash(error, default_status:)
      status = error[:status] || default_status
      pointer = error[:pointer] || error.dig(:source, :pointer)
      normalized = {
        status: status_to_string(status),
        detail: error[:detail] || error[:message] || error[:title] || 'Unknown error'
      }
      normalized[:code] = error[:code] if error[:code].present?
      normalized[:title] = error[:title] if error[:title].present?
      normalized[:source] = { pointer: pointer } if pointer.present?
      normalized[:meta] = error[:meta] if error[:meta].present?
      normalized
    end

    def status_to_string(status)
      return status if status.is_a?(String) && status.match?(/^\d+$/)

      Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status.to_sym, status).to_s
    rescue StandardError
      status.to_s
    end
  end
end

