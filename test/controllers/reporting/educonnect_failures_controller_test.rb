# frozen_string_literal: true

require "test_helper"

module Reporting
  class EduconnectFailuresControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "GET #index not logged fails" do
      get reporting_educonnect_failures_path
      assert_response :redirect
    end

    test "GET #index as operator fails" do
      sign_in(create(:user_operator))

      get reporting_educonnect_failures_path

      assert_response :redirect
      assert_redirected_to root_path
    end

    test "GET #index as god with no failure shows empty notice" do
      sign_in(create(:god))

      get reporting_educonnect_failures_path

      assert_response :success
      assert_equal "Aucune échec de connexion Educonnect n'a été enregistré pour le moment.",
                   flash[:notice]
    end

    test "GET #index as god above warning threshold shows alert" do
      sign_in(create(:god))
      create_list(:event_report, 101)

      get reporting_educonnect_failures_path

      assert_response :success
      assert_equal "Il y a actuellement 101 échec(s) de connexion Educonnect enregistré(s).",
                   flash[:alert]
    end

    test "GET #index as god above warning limit trims old failures" do
      sign_in(create(:god))
      create_list(:event_report, 1002)

      get reporting_educonnect_failures_path

      assert_response :success
      assert_equal 1000, EventReport.count
      assert_equal "Il y a actuellement plus de 1000 échec(s) de connexion Educonnect enregistré(s). Les plus anciens ont été supprimés pour éviter des problèmes de performance.",
                   flash[:alert]
    end
  end
end
