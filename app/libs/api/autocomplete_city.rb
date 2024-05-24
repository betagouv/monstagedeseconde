
module Api
  class AutocompleteCity
    API_ENDPOINT = "https://geo.api.gouv.fr/communes"


    def self.search(params)
      uri = URI("#{API_ENDPOINT}?#{params.to_query}")
      headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri, headers)

      http.request(request)
    end
  end
end