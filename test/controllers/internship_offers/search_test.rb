# frozen_string_literal: true

require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  test 'GET #search render default form' do
    get search_internship_offers_path

    assert_response :success
    assert_select 'button span.mr-2', text: 'Trouver un stage'
  end
end
