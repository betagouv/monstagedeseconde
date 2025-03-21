require 'test_helper'

class SygneImportTest < ActiveSupport::TestCase
  Monstage::Application.load_tasks
  include ThirdPartyTestHelpers

  setup do
    @code_uai = '0590116F'
    create(:school, code_uai: @code_uai)
    stub_omogen_auth
    # uri = URI(ENV['OMOGEN_OAUTH_URL'])
    # stub_request(:post, uri).to_return(body: { access_token: 'token' }.to_json)
    @headers = {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization' => 'Bearer token',
      'Compression-Zip' => 'non',
      'User-Agent' => 'Ruby'
    }
  end

  test 'student import fails with wrong codeMef' do
    stub_omogen_auth
    omogen = Services::Omogen::Sygne.new
    stub_sygne_eleves(code_uai: @code_uai, token: omogen.token)
    assert_no_difference 'Users::Student.count' do
      omogen.sygne_import_by_schools(@code_uai)
    end
  end

  test 'student import is ok with correct codeMef' do
    ine = '001291528AA'

    Services::Omogen::Sygne::MEFSTAT4_CODES.each do |niveau|
      uri = URI("#{ENV['SYGNE_URL']}/etablissements/#{@code_uai}/eleves?niveau=#{niveau}")
      expected_response = [{}]
      if Services::Omogen::Sygne::MEFSTAT4_CODES.first == niveau
        expected_response =
          [{
            'ine' => ine,
            'nom' => 'SABABADICHETTY',
            'prenom' => 'Felix',
            'dateNaissance' => '2003-05-28',
            'codeSexe' => '1',
            'codeUai' => '0590116F',
            'anneeScolaire' => 2023,
            'niveau' => '2212',
            'libelleNiveau' => '1ERE G-T',
            'codeMef' => '20010019110', # correct codeMef
            'libelleLongMef' => 'PREMIERE GENERALE',
            'codeMefRatt' => '20010019110',
            'classe' => '2E2',
            'codeRegime' => '2',
            'libelleRegime' => 'DP DAN',
            'codeStatut' => 'ST',
            'libelleLongStatut' => 'SCOLAIRE',
            'dateDebSco' => '2023-09-05',
            'adhesionTransport' => false
          }]
      end
      stub_request(:get, uri).with(headers: @headers)
                             .to_return(
                               status: 200,
                               body: expected_response.to_json,
                               headers: {}
                             )
    end
    uri = URI("#{ENV['SYGNE_URL']}/eleves/#{ine}/responsables")
    expected_response = [
      { nomFamille: 'BADEZ',
        prenom: 'Claudette',
        email: 'test@free.fr',
        telephonePersonnel: '04XXXXXXXX',
        adrResidenceResp: { adresseLigne1: '4, rue du Muguet',
                            adresseLigne2: 'Le Banel',
                            codePostal: '12110',
                            libelleCommune: 'AUBIN' },
        codeNiveauResponsabilite: '3',
        codeCivilite: '2' },
      { nomFamille: 'BADEZ',
        prenom: 'Gérard',
        email: 'test54@free.fr',
        telephonePersonnel: '0454XXXXXX',
        adrResidenceResp: { adresseLigne1: '4, rue du Muguet',
                            adresseLigne2: 'Le Banel',
                            codePostal: '12110',
                            libelleCommune: 'AUBIN' },
        codeNiveauResponsabilite: '2',
        codeCivilite: '1' }
    ]

    stub_request(:get, uri).with(headers: @headers)
                           .to_return(
                             status: 200,
                             body: expected_response.to_json,
                             headers: {}
                           )
    omogen = Services::Omogen::Sygne.new
    assert_difference 'ClassRoom.count', 1 do
      assert_difference 'Users::Student.count', 1 do
        omogen.sygne_import_by_schools(@code_uai)
      end
    end
  end
end
