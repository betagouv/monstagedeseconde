# frozen_string_literal: true

require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  test 'GET #search render default form' do
    skip 'SEARCH is not implemented yet to be finished by november 2024'
    get search_internship_offers_path

    assert_response :success
    assert_select 'button span.mr-2', text: 'Trouver un stage'
  end
end
