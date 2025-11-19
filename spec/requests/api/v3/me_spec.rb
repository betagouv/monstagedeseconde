# spec/requests/api/v3/me_spec.rb
require 'swagger_helper'

RSpec.describe 'api/v3/me', type: :request do
  path '/api/v3/me' do
    get 'Get current user info' do
      tags 'Users'
      security [bearerAuth: []]
      produces 'application/json'

      response(200, 'successful') do
        schema  type: :object,
                properties: {
                  id: {
                    type: 'integer',
                    example: 1 },
                  email: {
                    type: 'string',
                    format: 'email',
                    example: 'user@example.com'},
                  first_name:{
                    type: 'string',
                    example: 'John'},
                  last_name:{
                    type: 'string',
                    example: 'Doe'},
                  role: {
                    type: 'string',
                    example: 'employer'},
                  phone: {
                    type: 'string',
                    example: "+330612345678"},
                  school_id:{
                    type: 'integer',
                    example: 123},
                  operator_id:{
                    type: 'integer',
                    example: 456}
                }

        let(:Authorization) { "Bearer #{jwt_token}" }

        run_test!
      end

      response 401, 'unauthorized request' do
        schema '$ref' => '#/components/schemas/inline_response_401'
        run_test!
      end
    end
  end
end