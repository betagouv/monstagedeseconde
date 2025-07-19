# frozen_string_literal: true

require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  test 'GET #search render default form' do
    get search_internship_offers_path

    assert_response :success
    assert_select '.modal-title.col.text-center', text: 'Modifier ma recherche'
  end
end
