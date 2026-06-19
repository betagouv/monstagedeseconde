# frozen_string_literal: true

require 'test_helper'

class ApiEntrepriseProxyControllerTest < ActionDispatch::IntegrationTest
  def stub_recherche_entreprises(name:, nature_juridique:, est_service_public: nil)
    body = {
      results: [
        {
          nom_complet: name,
          nature_juridique: nature_juridique,
          complements: { est_service_public: est_service_public },
          siege: {
            siret: '13002526500013',
            activite_principale: '84.12Z',
            numero_voie: '20',
            type_voie: 'AV',
            libelle_voie: 'DE SEGUR',
            commune: '75007',
            libelle_commune: 'PARIS',
            adresse: '20 AV DE SEGUR 75007 PARIS'
          }
        }
      ]
    }.to_json

    stub_request(:get, %r{recherche-entreprises\.api\.gouv\.fr/search})
      .with(query: hash_including('q' => name))
      .to_return(status: 200, body: body, headers: { 'Content-Type' => 'application/json' })
  end

  test 'derives is_public: true for a public legal entity even when est_service_public is null (ANCT)' do
    stub_recherche_entreprises(
      name: 'ANCT',
      nature_juridique: '7389', # personne morale de droit public
      est_service_public: nil
    )

    get api_entreprise_proxy_search_path(name: 'ANCT')
    assert_response :success
    etablissement = JSON.parse(response.body)['etablissements'].first
    assert_equal true, etablissement['is_public']
  end

  test 'derives is_public: false for a commercial company' do
    stub_recherche_entreprises(
      name: 'EAST SIDE',
      nature_juridique: '5710', # SAS, société commerciale privée
      est_service_public: nil
    )

    get api_entreprise_proxy_search_path(name: 'EAST SIDE')
    assert_response :success
    etablissement = JSON.parse(response.body)['etablissements'].first
    assert_equal false, etablissement['is_public']
  end

  test 'still trusts est_service_public flag when present' do
    stub_recherche_entreprises(
      name: 'ETABLISSEMENT PUBLIC',
      nature_juridique: '4110', # not a "7…" code
      est_service_public: true
    )

    get api_entreprise_proxy_search_path(name: 'ETABLISSEMENT PUBLIC')
    assert_response :success
    etablissement = JSON.parse(response.body)['etablissements'].first
    assert_equal true, etablissement['is_public']
  end
end
