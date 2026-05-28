# frozen_string_literal: true

require 'test_helper'

module Api
  class ValidationErrorTest < ActiveSupport::TestCase
    test 'ValidationError can be initialized with code, error and status' do
      error = Api::ValidationError.new(
        code: 'TEST_CODE',
        error: 'Test error message',
        status: :bad_request
      )

      assert_equal 'TEST_CODE', error.code
      assert_equal 'Test error message', error.error_message
      assert_equal :bad_request, error.status
      assert_equal 'Test error message', error.message
    end
  end
end
