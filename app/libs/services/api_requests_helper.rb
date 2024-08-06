module Services
  class ApiRequestsHelper
    def get_request
      uri = get_request_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri, default_headers)
      http.request(request)
    end

    protected

    # expected: Int|Array[Int],
    # response: HttpResponse,
    def status?(expected, response)
      Array(expected).include?(response.code.to_i)
    end
  end
end
