require 'test_helper'

module Admin
  class ImportStudentsFromSygneTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def import_path(school)
      rails_admin.import_students_from_sygne_path(model_name: 'school', id: school.id)
    end

    test 'GET as God enqueues CountStudentsFromSygneJob and flashes success' do
      school = create(:school)
      sign_in(create(:god))

      assert_enqueued_with(job: CountStudentsFromSygneJob) do
        get import_path(school)
      end

      assert_response :redirect
      assert_match(/Recomptage des effectifs depuis Sygne lancé pour #{Regexp.escape(school.name)}/,
                   flash[:success])
    end

    test 'GET not logged in does not enqueue and redirects to sign in' do
      school = create(:school)

      assert_no_enqueued_jobs(only: CountStudentsFromSygneJob) do
        get import_path(school)
      end
      assert_redirected_to new_user_session_path
    end

    test 'GET as non-admin user does not enqueue and is denied' do
      school = create(:school, :with_school_manager)
      sign_in(school.school_manager)

      assert_no_enqueued_jobs(only: CountStudentsFromSygneJob) do
        get import_path(school)
      end
      assert_response :redirect
      assert_not_equal flash[:success], "Recomptage des effectifs depuis Sygne lancé pour #{school.name}."
    end

    test "GET on School show page renders the action link for God" do
      school = create(:school)
      sign_in(create(:god))

      get rails_admin.show_path(model_name: 'school', id: school.id)

      assert_response :success
      assert_match(/import_students_from_sygne/, response.body)
    end
  end
end
