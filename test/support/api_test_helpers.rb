module ApiTestHelpers

  def documents_as(endpoint:, state:)
    yield
    output_path = Rails.root.join('doc',
                                  'output',
                                  *endpoint.to_s.split('/'),
                                  "#{state}.json")
    File.write(output_path, pretty_json_response)
  end

  def json_response
    JSON.parse(response.body)
  rescue JSON::ParserError
    raise 'Not a json response'
  end

  def json_code
    json_response[0]['code']
  end

  def json_error
    json_response[0]['detail']
  end

  def json_errors
    Array(json_response['errors'])
  end

  def json_error_details
    json_errors.filter_map { |error| error['detail'] }
  end

  def json_data(index = nil)
    data = json_response['data']
    return data if index.nil?

    data.is_a?(Array) ? data[index] : data
  end

  def json_attributes(index = nil)
    data = json_data(index)
    return unless data.is_a?(Hash)

    data['attributes']
  end

  def json_id(index = nil)
    data = json_data(index)
    return unless data.is_a?(Hash)

    data['id']
  end

  def pretty_json_response
    body = JSON.parse(response.body)
    JSON.pretty_generate(body)
  rescue JSON::ParserError
    response.body
  end

  def dictionnary_api_call_stub
    stub_request(:any, /dictionnaire-academie.fr/).to_return(
      status: 200,
      body: '{"result":[{"nature":"n.f.","score":1}]}',
      headers: {}
    )
  end
end
