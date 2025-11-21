require 'swagger_helper'

RSpec.describe 'api/v3/internship_offers', type: :request do

  path '/api/v3/internship_offers/search' do

    get('search internship_offer') do
      tags 'internship_offers'
      response(200, 'successful') do

        parameter name: :params,
                  in: :query,
                  schema: { '$ref' => '#/definitions/parameters/internship_offer_query_params' }
        before do
          puts "🚀 Running internship offers search test"
        end
        
        after do |example|
          # This refers to the actual response object from the request
          let!(:internship_offer) { create(:weekly_internship_offer_3eme) }
          let!(:internship_offer) { create(:weekly_internship_offer_2nde) }
          # Add example attributes for documentation
          # example.metadata[:response][:content] = {
          #   'application/json' => {
          #     example: [internship_offer.attributes.symbolize_keys]
          #   }
          # }
          #
          Rails.logger.info("API Response Fields: #{JSON.parse(response.body).keys}")
 puts "=" * 50
  puts "API Response Body:"
  puts response.body
  puts "=" * 50
  puts "Parsed Response:"
  puts JSON.pretty_generate(JSON.parse(response.body))
  puts "=" * 50
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v3/internship_offers' do

    get('list internship_offers') do
      tags 'internship_offers'
      response(200, 'successful') do

        after do |example|
          Rails.logger.info("response body: #{response.body}")
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    post('create internship_offer') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v3/internship_offers/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    patch('update internship_offer') do
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    put('update internship_offer') do
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    delete('delete internship_offer') do
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
