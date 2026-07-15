# frozen_string_literal: true

require "test_helper"

module Dashboard::InternshipOffers
  class IndexTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    test "GET #edit as employer owning application student school renders success" do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)

      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                 internship_offer: internship_offer)
      internship_agreement = internship_application.internship_agreement
      sign_in(employer)

      get dashboard_internship_agreements_path
      assert_select("td[data-head='#{internship_application.internship_offer.title}']", count: 1)
      assert_response :success

      # testing discard at the same time
      internship_agreement.discard!
      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td[data-head='#{internship_application.internship_offer.title}']", count: 0)
    end

    test "GET #index as employer offers the blank agreement download" do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)
      employer, internship_offer = create_employer_and_offer_2nde
      create(:weekly_internship_application, :approved, student: student, internship_offer: internship_offer)
      sign_in(employer)

      get dashboard_internship_agreements_path

      assert_response :success
      assert_select "a[href=?]",
                    '/documents_utiles/convention_sequence_observation_milieu_pro_4eme_3eme_2ndeGT.pdf'
    end

    test "GET #index as employer shows the paper-only referent line when a referent is set" do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                 internship_offer: internship_offer)
      internship_agreement = internship_application.internship_agreement
      internship_agreement.update_columns(student_refering_teacher_full_name: 'Jean Prof')
      sign_in(employer)

      get dashboard_internship_agreements_path

      assert_response :success
      assert_select 'div', text: /Référent pédagogique \(signature papier uniquement\)/
    end

    test "GET #index as employer hides the referent line when referent is N\\/A" do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                 internship_offer: internship_offer)
      internship_agreement = internship_application.internship_agreement
      internship_agreement.update_columns(student_refering_teacher_full_name: 'N/A')
      sign_in(employer)

      get dashboard_internship_agreements_path

      assert_response :success
      assert_select 'div', text: /Référent pédagogique \(signature papier uniquement\)/, count: 0
    end

    test "GET #edit as employer when missing school_manager renders success even w/o school manager" do
      school = create(:school) # no_school_manager
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_application.student.update(school_id: school.id)
      internship_agreement = internship_application.internship_agreement
      sign_in(employer)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td.actions", text: "Remplir ma convention")
    end

    test "GET #index as school_manager when employer dit not complete the internship agreement" do
      school = create(:school, :with_school_manager)
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer: employer)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_application.student.update(school_id: school.id)
      InternshipAgreement.last.update(aasm_state: "draft")

      sign_in(school.school_manager)
      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td.actions", text: "En attente")
    end

    test "GET #index as school_manager when employer did complete the internship agreement" do
      school = create(:school, :with_school_manager)
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer: employer)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_application.student.update(school_id: school.id)

      InternshipAgreement.last.update(aasm_state: "completed_by_employer")

      sign_in(school.school_manager)
      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td.actions", text: "Remplir ma convention")
    end
    test "GET #index as school_manager when employer signed the internship agreement" do
      school = create(:school, :with_school_manager)
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer: employer)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_application.student.update(school_id: school.id)

      InternshipAgreement.last.update(aasm_state: "signatures_started")
      create(:signature, :employer, internship_agreement: InternshipAgreement.last)

      sign_in(school.school_manager)
      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td.actions", text: "SignerTélécharger")
    end
    test "GET #index as school_manager when school manager signed the internship agreement" do
      school = create(:school, :with_school_manager)
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer: employer)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_application.student.update(school_id: school.id)

      InternshipAgreement.last.update(aasm_state: "signatures_started")
      create(:signature, :school_manager, internship_agreement: InternshipAgreement.last)

      sign_in(school.school_manager)
      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td.actions", text: "Déjà signéeTélécharger")
    end
    test "GET #index as school_manager when everyone signed the internship agreement" do
      school = create(:school, :with_school_manager)
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer: employer)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_application.student.update(school_id: school.id)

      InternshipAgreement.last.update(aasm_state: "signed_by_all")

      sign_in(school.school_manager)
      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td.actions", text: "Signée de tousTélécharger")
    end

    test "GET #index as teacher " do
      school = create(:school, :with_school_manager)
      teacher = create(:teacher, school: school)
      internship_offer = create(:weekly_internship_offer_2nde, employer: create(:employer))
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      internship_application.student.update(school_id: school.id)
      internship_agreement = internship_application.internship_agreement

      sign_in(teacher)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td[data-head='#{internship_application.internship_offer.title}']")
    end

    test "GET #index as admin_officer " do
      school = create(:school, :with_school_manager)
      teacher = create(:admin_officer, school: school)
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      # internship_agreement = internship_application.internship_agreement

      sign_in(teacher)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td[data-head='#{internship_application.internship_offer.title}']")
    end

    test "GET #index as cpe " do
      school = create(:school, :with_school_manager)
      cpe = create(:cpe, school: school)
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      # internship_agreement = internship_application.internship_agreement

      sign_in(cpe)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td[data-head='#{internship_application.internship_offer.title}']")
    end
  end
end
