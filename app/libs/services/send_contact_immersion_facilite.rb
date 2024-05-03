module Services
  class SendContactImmersionFacilite
    
    IMMERSION_FACILITE_ENDPOINT_URL = ENV['IMMERSION_FACILE_API_URL'] + '/contact-establishment'

    def perform
      response = post_request

      unless response&.respond_to?(:body)
        error_message = "Faulty request : consider contacting developper"
        Rails.logger.error(error_message)
        return false
      end

      if response && response.respond_to?(:code) && successful_status?(response.code)
        true
      else
        log_failure(response)
        false
      end
    end

    private

    def log_failure(response)
      error_message = "Error #{response.try(:code)} with message: " \
                      "#{response} for immmersion-facilitée"
      Rails.logger.error(error_message)
    end

    def post_request
      # post request to immersion facile with body
      uri = get_request_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri, default_headers)
      request.body = body_request.to_json
      http.request(request)
    end

    def successful_status?(response_code)
      [200, 201].include?(response_code.to_i)
    end


    def get_request_uri
      URI(IMMERSION_FACILITE_ENDPOINT_URL)
    end

    def body_request
      {
        "potentialBeneficiaryFirstName": first_name,
        "potentialBeneficiaryLastName": last_name,
        "potentialBeneficiaryEmail": email,
        "appellationCode": appellation_code,
        "siret": siret,
        "contactMode": "EMAIL",
        "message": 'message',
        "potentialBeneficiaryPhone": phone,
        "immersionObjective": "Découvrir un métier ou un secteur d'activité",
        "locationId": location_id
      }
    end

    # expected: Int|Array[Int],
    # response: HttpResponse,
    def status?(expected, response)
      Array(expected).include?(response.code.to_i)
    end

    def default_headers
      {
        'Accept': 'application/json' ,
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