# frozen_string_literal: true

require 'application_system_test_case'

module Product
  class HomeValidationTest < ApplicationSystemTestCase

    include Html5Validator
    include Devise::Test::IntegrationHelpers


    test 'USE_W3C, static pages' do
      %i[
        accessibilite_path
        conditions_d_utilisation_path
        contact_path
        eleves_path
        equipe_pedagogique_path
        inscription_permanence_path
        mentions_legales_path
        operators_path
        politique_de_confidentialite_path
        professionnels_path
        partenaires_regionaux_path
        referents_path
        root_path
      ].map do |page_path|
        run_request_and_cache_response(report_as: page_path.to_s) do
          visit Rails.application.routes.url_helpers.send(page_path)
        end
      end
    end
  end
end
