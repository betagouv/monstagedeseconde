module Services
  module ApiRequestsHelper
    def get_request(uri, default_headers = {})
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      request = Net::HTTP::Get.new(uri, default_headers)
      http.request(request)
    end

    def post_request(body:, uri:, default_headers: {})
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri, default_headers)
      request.body = body.to_json
      http.request(request)
    end

    def post_form_request(url:, params:)
      Net::HTTP.post_form(URI(url), params)
    end

    def put_request(body:, uri:, default_headers: {})
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      request = Net::HTTP::Put.new(uri, default_headers)
      request.body = body.to_json
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
