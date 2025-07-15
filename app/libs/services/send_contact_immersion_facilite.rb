module Services
  class SendContactImmersionFacilite
    include ApiRequestsHelper
    IMMERSION_FACILITE_ENDPOINT_URL = ENV['IMMERSION_FACILE_API_URL'] + '/contact-establishment'

    def perform
      response = post_request(
        body: body_request,
        uri: URI(IMMERSION_FACILITE_ENDPOINT_URL),
        default_headers: default_headers
      )

      unless response&.respond_to?(:body)
        error_message = 'Faulty request : consider contacting developper'
        Rails.logger.error(error_message)
        return false
      end

      is_success = response && response.respond_to?(:code) && successful_status?(response.code)
      log_failure(response) unless is_success
      is_success
    end

    private

    def log_failure(response)
      error_message = "Error #{response.try(:code)} with message: " \
                      "#{response} for immmersion-facilitée"
      Rails.logger.error(error_message)
    end

    def successful_status?(response_code)
      [200, 201].include?(response_code.to_i)
    end

    def body_request
      {
        "potentialBeneficiaryFirstName": first_name,
        "potentialBeneficiaryLastName": last_name,
        "potentialBeneficiaryEmail": email,
        "appellationCode": appellation_code,
        "siret": siret,
        "contactMode": 'EMAIL',
        "message": message,
        "potentialBeneficiaryPhone": phone,
        "immersionObjective": "Découvrir un métier ou un secteur d'activité",
        "locationId": location_id
      }
    end

    def default_headers
      {
        'Accept': 'application/json',
        'Authorization': ENV['IMMERSION_FACILE_API_KEY'],
        'Content-Type': 'application/json'
      }
    end

    attr_reader :first_name, :last_name, :email, :phone, :appellation_code, :siret, :message, :location_id

    private

    def initialize(params)
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      @email = params[:email]
      @phone = params[:phone]
      @appellation_code = params[:appellation_code]
      @siret = params[:siret]
      @message = params[:message]
      @location_id = params[:location_id]
    end
  end
end
