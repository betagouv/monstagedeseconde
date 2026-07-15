# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # Edit, SchoolManagement
    #
    test 'GET edit not logged redirects to sign in' do
      school = create(:school)
      get edit_dashboard_school_path(school.to_param)
      assert_redirected_to user_session_path
    end

    test 'GET edit as Student redirects to root path' do
      school = create(:school)
      sign_in(create(:student))
      get edit_dashboard_school_path(school.to_param)
      assert_redirected_to root_path
    end

    test 'GET edit as God works' do
      school = create(:school)
      sign_in(create(:god))

      get edit_dashboard_school_path(school.to_param)

      assert_response :success
    end

    #
    # Update as Visitor
    #
    test 'PATCH update not logged redirects to sign in' do
      school = create(:school)
      patch(dashboard_school_path(school.to_param),
            params: {
              school: {
                weeks_ids: [weeks(:week_2025_1).id, weeks(:week_2025_2).id]
              }
            })
      assert_redirected_to user_session_path
    end

    test 'PATCH update as Student redirects to root path' do
      school = create(:school)
      sign_in(create(:student))
      patch(dashboard_school_path(school.to_param),
            params: {
              school: {
                weeks_ids: [weeks(:week_2025_1).id, weeks(:week_2025_2).id]
              }
            })
      assert_redirected_to root_path
    end

    test 'PATCH update with missing params fails gracefuly' do
      school = create(:school)
      sign_in(create(:school_manager, school: school))
      patch(dashboard_school_path(school.to_param), params: {})
      assert_response :unprocessable_entity
    end

    #
    # Cross-school authorization (regression)
    #
    test 'GET edit on another school as SchoolManager is forbidden' do
      own_school = create(:school)
      other_school = create(:school)
      sign_in(create(:school_manager, school: own_school))

      get edit_dashboard_school_path(other_school.to_param)

      assert_redirected_to root_path
    end

    test 'PATCH update on another school as SchoolManager is forbidden' do
      own_school = create(:school)
      other_school = create(:school)
      original_signature = other_school.signature
      sign_in(create(:school_manager, school: own_school))

      patch(dashboard_school_path(other_school.to_param),
            params: { school: { signature: 'spoofed' } })

      assert_redirected_to root_path
      assert_equal original_signature, other_school.reload.signature
    end

    test 'PATCH update on another school as Teacher is forbidden' do
      own_school = create(:school)
      other_school = create(:school)
      sign_in(create(:teacher, school: own_school))

      patch(dashboard_school_path(other_school.to_param),
            params: { school: { signature: 'spoofed' } })

      assert_redirected_to root_path
    end

    test 'PATCH update_signature on another school as SchoolManager is forbidden' do
      own_school = create(:school)
      other_school = create(:school)
      original_signature = other_school.signature
      sign_in(create(:school_manager, school: own_school))

      patch(update_signature_dashboard_school_path(other_school.to_param),
            params: { school: { signature: 'spoofed' } })

      assert_redirected_to root_path
      assert_equal original_signature, other_school.reload.signature
    end

    #
    # update_header_logo
    #
    test 'PATCH update_header_logo as SchoolManager attaches the logo' do
      school = create(:school)
      sign_in(create(:school_manager, school: school))

      logo = fixture_file_upload('signature.png', 'image/png')
      patch(update_header_logo_dashboard_school_path(school.to_param),
            params: { school: { header_logo: logo } })

      assert_redirected_to dashboard_internship_agreements_path
      assert school.reload.header_logo.attached?
    end

    test 'PATCH update_header_logo with an invalid file does not attach' do
      school = create(:school)
      sign_in(create(:school_manager, school: school))

      invalid_file = fixture_file_upload('signature.json', 'application/json')
      patch(update_header_logo_dashboard_school_path(school.to_param),
            params: { school: { header_logo: invalid_file } })

      assert_redirected_to dashboard_internship_agreements_path
      refute school.reload.header_logo.attached?
    end

    test 'PATCH update_header_logo on another school as SchoolManager is forbidden' do
      own_school = create(:school)
      other_school = create(:school)
      sign_in(create(:school_manager, school: own_school))

      logo = fixture_file_upload('signature.png', 'image/png')
      patch(update_header_logo_dashboard_school_path(other_school.to_param),
            params: { school: { header_logo: logo } })

      assert_redirected_to root_path
      refute other_school.reload.header_logo.attached?
    end

    test 'PATCH update_header_logo as Student is forbidden' do
      school = create(:school)
      sign_in(create(:student, school: school))

      logo = fixture_file_upload('signature.png', 'image/png')
      patch(update_header_logo_dashboard_school_path(school.to_param),
            params: { school: { header_logo: logo } })

      assert_redirected_to root_path
      refute school.reload.header_logo.attached?
    end
  end
end
