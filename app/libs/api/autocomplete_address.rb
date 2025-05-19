module Api
  class AutocompleteAddress
    # see: https://geo.api.gouv.fr/adresse
    API_ENDPOINT = 'https://data.geopf.fr/geocodage/search'

    def self.search(params:)
      uri = URI(API_ENDPOINT)
      uri.query = URI.encode_www_form({ q: params[:q], limit: params.fetch(:limit) { 10 } })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      response.body
    end
  end
end
