class CaptchaController < ApplicationController
  def generate
    uri = URI.parse('https://api.gouv.fr/documentation/api-captchetat/generate')
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{ENV['CAPTCHA_API_KEY']}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    render json: response.body
  end

  def verify
    uri = URI.parse('https://api.gouv.fr/documentation/api-captchetat/verify')
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{ENV['CAPTCHA_API_KEY']}"
    request['Content-Type'] = 'application/json'
    request.body = {
      token: params[:token],
      response: params[:response]
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    render json: response.body
  end
end
