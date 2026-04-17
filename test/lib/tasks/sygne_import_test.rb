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
    stub_sygne_eleves(code_uai: @code_uai, token: omogen.token, code_mef: 'wrong_code')
    assert_no_difference 'Users::Student.count' do
      omogen.sygne_import_by_schools(@code_uai)
    end
  end

  test 'student import updates class_room when student already exists' do
    school = School.find_by(code_uai: @code_uai)
    grade = Grade.find_by(short_name: 'troisieme')
    old_class_room = create(:class_room, name: '3E1', school: school, grade: grade)
    student = create(:student, ine: '001291528AA', school: school, class_room: old_class_room, grade: grade)

    omogen = Services::Omogen::Sygne.new
    stub_sygne_eleves(code_uai: @code_uai, token: omogen.token, classe: '3E4')

    assert_no_difference 'Users::Student.count' do
      omogen.sygne_import_by_schools(@code_uai)
    end

    student.reload
    assert_equal '3E4', student.class_room.name
    assert_not_equal old_class_room.id, student.class_room_id
  end

  test 'student import is ok with correct codeMef' do
    ine = '001291528AA'

    stub_sygne_eleves(code_uai: @code_uai, token: Services::Omogen::Sygne.new.token)
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
