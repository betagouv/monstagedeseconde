require 'swagger_helper'

RSpec.describe 'api/v3/auth/login', type: :request do
  path '/api/v3/auth/login' do
    post 'Authentifie un utilisateur et retourne un token JWT' do
      tags 'current user'
      consumes 'application/json'
      # parameter schema: {
      parameter name: 'login', in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com', maxLength: 70 },
          password: { type: :string , example: 'password123', minLength: 12 }
        },
        required: [ 'email', 'password' ]
      }
      produces 'application/json'

      response '200', 'success: token returned' do
        schema type: :object,
                properties: {
                  token: {
                  type: :string,
                  example: "eyJhbGciOiJIUzI1NiIsInR5ciOiJKV1QiLCJ9..."  },
                user_id: { type: :integer, example: 1  },
                issued_at: {
                  type: :string,
                  format: :'date-time',
                  example: "2024-06-10T12:34:56Z"  }
                },
                example: {token: "eyJhbGciOiJIUzI1NiIsInR5ciOiJKV1QiLCJ9..."}
        run_test!
      end

      response 401, 'unauthorized request' do
        schema '$ref' => '#/components/schemas/inline_response_401'
        run_test!
      end
    end
  end
end