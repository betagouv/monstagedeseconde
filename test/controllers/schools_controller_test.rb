require 'test_helper'

class SchoolsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ThirdPartyTestHelpers
  include ActiveJob::TestHelper

  test 'GET new not logged redirects to sign in' do
    get new_school_path
    assert_redirected_to user_session_path
  end

  test 'GET new not god redirects to root' do
    employer = create(:employer)
    sign_in(employer)
    get new_school_path
    assert_redirected_to root_path
  end

  test 'GET new when god it renders the page' do
    god = create(:god)
    sign_in(god)
    get new_school_path
    assert_response :success
  end

  test 'POST #create as god redirects to admin' do
    stub_omogen_auth
    omogen = Services::Omogen::Sygne.new

    god = create(:god)
    sign_in(god)
    school_params = {
      name: 'Victor Hugo',
      code_uai: '1234567X',
      street: '1 rue de Rivoli',
      contract_code: '30',
      is_public: false,
      zipcode: '75001',
      city: 'Paris',
      visible: 1,
      school_type: 'lycee',
      voie_generale: true,
      voie_techno: false,
      coordinates: {
        latitude: 48.866667,
        longitude: 2.333333
      }
    }

    stub_sygne_eleves(code_uai: school_params[:code_uai], token: omogen.token)

    assert_enqueued_with(job: ImportDataFromSygneJob) do
      assert_difference('School.count', 1) do
        post schools_path(school: school_params)
      end
    end
    school = School.last
    assert_redirected_to rails_admin_path
    assert_equal school.name, 'Victor Hugo'
    assert_equal school.code_uai, '1234567X'
    assert_equal school.street, '1 rue de Rivoli'
    assert_equal school.zipcode, '75001'
    assert_equal school.city, 'Paris'
    assert_equal school.visible, true
    assert_equal school.legal_status, 'Privé sous contrat'
    assert_equal school.school_type, 'lycee'
    assert_equal school.voie_generale, true
    assert_equal school.voie_techno, false
  end

  test 'update school signature with image' do
    school = create(:school, :with_school_manager)
    sign_in(school.school_manager)
    patch dashboard_school_path(school),
          params: { school: { signature: fixture_file_upload('signature.png', 'image/png') } }
    assert_redirected_to dashboard_school_class_rooms_path(school.id)
    school.reload
    assert_equal 'signature.png', school.signature.filename.to_s
  end

  test 'update school signature with no image' do
    school = create(:school, :with_school_manager)
    sign_in(school.school_manager)
    patch dashboard_school_path(school), params: { school: { signature: nil } }
    assert_redirected_to dashboard_school_class_rooms_path(school.id)

    school.reload
    assert_not school.signature.attached?
  end
end
