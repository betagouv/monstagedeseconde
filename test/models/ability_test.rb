# frozen_string_literal: true

require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  test 'Visitor' do
    ability = Ability.new
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internships')
    assert(ability.can?(:apply, InternshipOffer.new),
           'visitors should be lured into thinking that they can apply directly')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test 'Student' do
    travel_to Date.new(2024, 9, 1) do
      internship_offer = create(:weekly_internship_offer_3eme)
      school = create(:school)
      class_room = create(:class_room, school:)
      student = create(:student, class_room:, school:)
      other_student = create(:student, class_room:, school:)
      ability = Ability.new(student)
      internship_application = create(:weekly_internship_application,
                                      student:,
                                      internship_offer:)
      validated_internship_application = create(:weekly_internship_application,
                                                :validated_by_employer,
                                                student: other_student,
                                                internship_offer:)
      assert(ability.can?(:look_for_offers, student), 'students should be able to look for offers')
      assert(ability.can?(:read, InternshipOffer.new),
             'students should be able to consult internship offers')
      refute(ability.can?(:apply, internship_offer),
             'students should not be able to apply for internship offers')
      assert(ability.cannot?(:manage, InternshipOffer.new),
             'students should not be able to con manage internships')
      assert(ability.can?(:show, :account),
             'students should be able to access their account')
      assert(ability.can?(:dashboard_index, student))
      assert(ability.can?(:dashboard_show, internship_application))
      assert(ability.can?(:internship_application_edit, internship_application))
      assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))
      assert(ability.cannot?(:index, Acl::InternshipOfferDashboard.new(user: student)),
             'employers should be able to index InternshipOfferDashboard')
      refute(ability.can?(:read_employer_data, internship_application),
             'student shall not read employer data unless internship_application is validated')
      ability = Ability.new(other_student)
      assert(ability.can?(:read_employer_data, validated_internship_application),
             'student shall read employer data when internship_application is validated')

      student_2 = create(:student) # with no class_room, no school
      ability = Ability.new(student_2)
      assert(ability.can?(:apply, internship_offer),
             'students without school or class_room should be able to apply for internship offers')
      assert(ability.can?(:read_employer_name, internship_offer),
             'students should be able to read city with ms2e internship offers')
      operator = create(:operator_with_departments)
      operator_with_masked_data = create(:operator_with_departments, masked_data: true)
      assert operator.departments.any?

      api_internship_offer_3eme = create(:api_internship_offer_2nde, employer: create(:user_operator, operator:),
                                                                     city: 'truc', zipcode: '60000')
      api_internship_offer_paris = create(:api_internship_offer_2nde, employer: create(:user_operator, operator:),
                                                                      city: 'Paris', zipcode: '75012')
      refute(ability.can?(:read_employer_name, api_internship_offer_3eme),
             "students should not be able to read city in a 'protected' api internship offers")
      assert(ability.can?(:read_employer_name, api_internship_offer_paris),
             "students should not be able to read city in a 'protected' api internship offers")
      api_internship_offer_3eme = create(:api_internship_offer_3eme,
                                         employer: create(:user_operator, operator: operator_with_masked_data), city: 'truc', zipcode: '60000')
      refute(ability.can?(:read_employer_name, api_internship_offer_3eme),
             "students should not be able to read city in a 'protected' api internship offers")
    end
  end

  test 'Employer' do
    skip 'leak suspicion'
    travel_to Date.new(2025, 1, 1) do
      employer = create(:employer)
      another_employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer:)
      old_internship_offer = create(:weekly_internship_offer_2nde, employer:, created_at: 1.year.ago,
                                                                   weeks: [SchoolTrack::Seconde.first_week(year: 2024)])
      assert old_internship_offer.employer == employer
      alt_internship_offer = create(:weekly_internship_offer_2nde, employer: another_employer)
      internship_offer_api = create(:api_internship_offer_3eme, employer:)
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_application_other = create(:weekly_internship_application, internship_offer: alt_internship_offer)
      internship_agreement = create(:internship_agreement, :created_by_system,
                                    internship_application:)
      ability = Ability.new(employer)

      assert(ability.can?(:choose_function, User.new),
             'employers can declare their role in their organisation')
      assert(ability.can?(:subscribe_to_webinar, User.new),
             'employers can subscribe to webinars')
      assert(ability.can?(:supply_offers, employer), 'employers are to be able to supply offers')
      assert(ability.can?(:create, InternshipOffer.new),
             'employers should be able to create internships')
      refute(ability.can?(:update, InternshipOffer.new),
             'employers should not be able to update internship offer not belonging to him')
      refute(ability.can?(:udpate, old_internship_offer), 'Offer can only be duplicated')
      assert(ability.can?(:update, internship_offer),
             'employers should be able to update internships offer that belongs to him')

      assert(ability.cannot?(:discard, InternshipOffer.new),
             'employers should be able to discard internships offer not belonging to him')
      assert(ability.can?(:discard, InternshipOffer.new(employer:)),
             'employers should be able to discard internships offer that belongs to him')
      assert(ability.can?(:index, Acl::InternshipOfferDashboard.new(user: employer)),
             'employers should be able to index InternshipOfferDashboard')

      team_member_invitation = create(:team_member_invitation, inviter: employer,
                                                               member: another_employer, invitation_email: another_employer.email)
      team_member_invitation.accept_invitation!
      colleague_offer = create(:weekly_internship_offer_2nde, employer: another_employer)
      internship_application = create(:weekly_internship_application, internship_offer: colleague_offer)

      ability = Ability.new(employer)
      assert(ability.can?(:show, internship_application),
             'employer should be able to show application related to team')

      %i[
        create
        edit
        edit_organisation_representative_role
        edit_tutor_email
        edit_tutor_role
        edit_activity_scope
        edit_activity_preparation
        edit_activity_learnings
        edit_date_range
        edit_organisation_representative_full_name
        edit_siret
        edit_tutor_full_name
        edit_weekly_hours
        update
      ].each do |meth|
        assert(ability.can?(meth, internship_agreement), "Employer fail: #{meth}")
      end
      internship_agreement.update_columns(aasm_state: :started_to_sign)
      assert(ability.can?(:sign_with_sms, User))
      assert(ability.can?(:sign_internship_agreements, internship_agreement.reload), 'Signature fails')
      assert(ability.can?(:transfer, internship_application.reload), 'Transfer my own application fails')
      #       refute(ability.can?(:transfer, internship_application_other.reload), 'Transfer my own application fails')
    end
  end

  test 'God' do
    travel_to Date.new(2023, 10, 1) do
      god = build(:god)
      ability = Ability.new(god)
      assert(ability.can?(:show, :account),
             'god should be able to see his account')
      assert(ability.can?(:update, School),
             'god should be able to manage school')
      assert(ability.can?(:edit, User),
             'god should be able to edit user')
      assert(ability.can?(:see_tutor, InternshipOffer),
             'god should be able see_tutor')
      assert ability.can?(:read, User)
      assert ability.can?(:destroy, User)
      assert ability.can?(:manage, Group)
      assert ability.can?(:index_and_filter, Reporting::InternshipOffer)
      assert ability.can?(:index, Acl::Reporting.new(user: god, params: {}))
      refute ability.can?(:apply, create(:weekly_internship_offer_2nde))
      refute ability.can?(:apply, create(:api_internship_offer_3eme))
      assert ability.can?(:new, InternshipAgreement)
      assert ability.can?(:see_reporting_dashboard, User)
      assert ability.can?(:see_reporting_internship_offers, User)
      assert ability.can?(:see_reporting_schools, User)
      assert ability.can?(:see_reporting_associations, User)
      assert ability.can?(:see_reporting_enterprises, User)
    end
  end

  test 'Statistician' do
    travel_to Date.new(2023, 10, 1) do
      statistician = create(:statistician)
      ability = Ability.new(statistician)

      assert(ability.can?(:supply_offers, statistician), 'statistician are to be able to supply offers')
      assert(ability.can?(:view, :department),
             'statistician should be able to view his own department')
      assert(ability.can?(:read, InternshipOffer))
      assert(ability.cannot?(:renew, InternshipOffer.new),
             'employers should not be able to renew internship offer not belonging to him')
      refute(ability.can?(:show, :account),
             'statistician should be able to see his account')
      refute(ability.can?(:update, School),
             'statistician should be able to manage school')
      refute(ability.can?(:edit, User),
             'statistician should be able to edit user')
      refute(ability.can?(:check_his_statistics, User),
             'statistician should be able to check his statistics')
      refute ability.can?(:read, User)
      refute ability.can?(:destroy, User)
      assert ability.can?(:index_and_filter, Reporting::InternshipOffer)
      # TODO: fix this test
      #     refute ability.can?(:index, Acl::Reporting.new(user: statistician, params: {}))
      assert(ability.can?(:index, Acl::Reporting, &:allowed?))

      refute ability.can?(:apply, create(:weekly_internship_offer_2nde))
      refute ability.can?(:apply, create(:api_internship_offer_3eme))

      assert ability.can?(:see_reporting_dashboard, User)
      refute ability.can?(:see_dashboard_enterprises_summary, User)
      refute ability.can?(:see_reporting_schools, User)
      refute ability.can?(:see_reporting_associations, User)
      refute ability.can?(:see_reporting_enterprises, User)

      assert(ability.can?(:edit, InternshipAgreement))
      assert(ability.can?(:create, InternshipAgreement))
      assert(ability.can?(:update, InternshipAgreement))

      statistician = create(:statistician, agreement_signatorable: true)
      ability = Ability.new(statistician)
      assert(ability.can?(:edit, InternshipAgreement))
      assert(ability.can?(:create, InternshipAgreement))
      assert(ability.can?(:update, InternshipAgreement))
    end
  end

  test 'Education Statistician' do
    travel_to Date.new(2023, 10, 1) do
      statistician = create(:education_statistician)
      ability = Ability.new(statistician)

      assert(ability.can?(:supply_offers, statistician), 'statistician are to be able to supply offers')
      assert(ability.can?(:view, :department),
             'statistician should be able to view his own department')
      assert(ability.can?(:read, InternshipOffer))
      assert(ability.cannot?(:renew, InternshipOffer.new),
             'employers should not be able to renew internship offer not belonging to him')
      refute(ability.can?(:show, :account),
             'statistician should be able to see his account')
      refute(ability.can?(:update, School),
             'statistician should be able to manage school')
      refute(ability.can?(:edit, User),
             'statistician should be able to edit user')
      assert(ability.can?(:subscribe_to_webinar, User.new),
             'statisticians can subscribe to webinars')
      refute ability.can?(:read, User)
      refute ability.can?(:destroy, User)
      # TODO: fix this test
      #     assert ability.can?(:index_and_filter, Reporting::InternshipOffer)
      refute ability.can?(:index, Acl::Reporting.new(user: statistician, params: {}))
      assert(ability.can?(:index, Acl::Reporting, &:allowed?))

      refute ability.can?(:apply, create(:weekly_internship_offer_2nde))
      refute ability.can?(:apply, create(:api_internship_offer_3eme))

      assert ability.can?(:see_reporting_dashboard, User)
      refute ability.can?(:see_dashboard_enterprises_summary, User)
      refute ability.can?(:see_reporting_schools, User)
      refute ability.can?(:see_reporting_associations, User)
      refute ability.can?(:see_reporting_enterprises, User)

      refute(ability.can?(:edit, InternshipAgreement))
      refute(ability.can?(:create, InternshipAgreement))
      refute(ability.can?(:update, InternshipAgreement))

      statistician = create(:education_statistician, agreement_signatorable: true)
      ability = Ability.new(statistician)
      assert(ability.can?(:edit, InternshipAgreement))
      assert(ability.can?(:create, InternshipAgreement))
      assert(ability.can?(:update, InternshipAgreement))
    end
  end

  test 'MinistryStatistician' do
    travel_to Date.new(2023, 10, 1) do
      ministry_statistician = create(:ministry_statistician)
      ministry = ministry_statistician.ministries.first
      ability = Ability.new(ministry_statistician)

      assert(ability.can?(:supply_offers, ministry_statistician), 'statistician are to be able to supply offers')
      assert(ability.can?(:index, Acl::Reporting, &:allowed?))
      assert(ability.can?(:read, Group),
             'ministry statistician should be able to view his own ministry')
      refute(ability.can?(:show, :account),
             'ministry_statistician should be able to see his account')
      refute(ability.can?(:update, School),
             'ministry_statistician should be able to manage school')
      refute(ability.can?(:edit, User),
             'ministry_statistician should be able to edit user')
      assert(ability.can?(:subscribe_to_webinar, ministry_statistician),
             'statisticians can subscribe to webinars')
      assert(ability.can?(:see_tutor, InternshipOffer),
             'ministry_statistician should be able see_tutor')
      refute ability.can?(:read, User)
      refute ability.can?(:destroy, User)
      assert ability.can?(:index_and_filter, Reporting::InternshipOffer)

      offer = create(:weekly_internship_offer_3eme,
                     group_id: ministry.id,
                     employer: ministry_statistician,
                     is_public: true)

      refute ability.can?(:apply, create(:weekly_internship_offer_2nde))
      refute ability.can?(:apply, create(:api_internship_offer_3eme))

      assert ability.can?(:see_reporting_dashboard, User)
      refute ability.can?(:see_reporting_internship_offers, User)
      refute ability.can?(:see_reporting_schools, User)
      refute ability.can?(:see_reporting_associations, User)
      refute ability.can?(:see_reporting_entreprises, User)
      assert ability.can?(:see_ministry_dashboard, User)

      refute(ability.can?(:edit, InternshipAgreement))
      refute(ability.can?(:create, InternshipAgreement))
      refute(ability.can?(:update, InternshipAgreement))

      statistician = create(:ministry_statistician, agreement_signatorable: true)
      ability = Ability.new(statistician)
      assert(ability.can?(:edit, InternshipAgreement))
      assert(ability.can?(:create, InternshipAgreement))
      assert(ability.can?(:update, InternshipAgreement))
    end
  end

  test 'SchoolManager' do
    student = create(:student)
    school = student.school
    another_school          = create(:school)
    school_manager          = create(:school_manager, school:)
    another_school_manager  = create(:school_manager, school: another_school)
    internship_application  = create(:weekly_internship_application, student:)
    invitation              = create(:invitation, user_id: school_manager.id)
    invitation_other_school = create(:invitation, user_id: another_school_manager.id)
    internship_agreement    = create(:internship_agreement, :created_by_system,
                                     internship_application:)
    ability = Ability.new(school_manager)

    assert(ability.can?(:create_invitation, invitation))
    refute(ability.can?(:create_invitation, invitation_other_school))
    assert(ability.can?(:list_invitations, invitation))
    refute(ability.can?(:list_invitations, invitation_other_school))

    assert(ability.can?(:welcome_students, school_manager), 'school_manager are to be able to supply offers')
    assert(ability.can?(:choose_class_room, User))
    refute(ability.can?(:choose_role, User))
    assert(ability.can?(:choose_class_room, User))
    assert(ability.can?(:sign_with_sms, User))
    assert(ability.can?(:subscribe_to_webinar, school_manager))
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:delete, student))

    assert(ability.can?(:index, ClassRoom))
    assert(ability.cannot?(:change, :class_room))

    assert(ability.can?(:destroy, internship_application))
    assert(ability.can?(:update, internship_application))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.can?(:submit_internship_application, internship_application))
    assert(ability.can?(:validate_convention, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))

    assert(ability.can?(:see_tutor, InternshipOffer))

    assert(ability.can?(:manage_school_users, school))
    assert(ability.can?(:manage_school_students, school))
    assert(ability.can?(:manage_school_internship_agreements, school))

    assert(ability.cannot?(%i[show edit update], School),
           'school_manager should be able manage school')
    assert(ability.cannot?(:manage_school_users, another_school))
    assert(ability.cannot?(:manage_school_students, another_school))

    assert(ability.can?(:create, InternshipAgreement))
    %i[create
       edit
       edit_activity_rating
       edit_financial_conditions_rich_text
       edit_legal_terms_rich_text
       edit_school_representative_full_name
       edit_school_representative_phone
       edit_school_representative_email
       edit_school_representative_role
       edit_student_refering_teacher_email
       edit_student_refering_teacher_phone
       edit_student_address
       edit_student_class_room
       edit_student_full_name
       edit_student_phone
       edit_student_legal_representative_email
       edit_student_legal_representative_full_name
       edit_student_legal_representative_phone
       edit_student_legal_representative_2_email
       edit_student_legal_representative_2_full_name
       edit_student_legal_representative_2_phone
       edit_student_school
       see_intro
       update ].each do |dedicated_ability|
      assert(ability.can?(dedicated_ability, internship_agreement))
    end
    internship_agreement.update_columns(aasm_state: :validated)
    assert(ability.can?(:sign_internship_agreements, internship_agreement.reload), 'Ability : Signature fails')
  end

  test 'MainTeacher' do
    student = create(:student)
    school = student.school
    another_school = create(:school)
    school_manager = create(:school_manager, school:)
    class_room = create(:class_room, school:)
    main_teacher = create(:main_teacher, school:, class_room:)
    internship_application = create(:weekly_internship_application, student:)
    internship_agreement   = create(:internship_agreement, :created_by_system,
                                    internship_application:)
    ability = Ability.new(main_teacher)

    assert(ability.can?(:welcome_students, main_teacher),
           'main_teacher are to be able to welcome students')
    assert(ability.can?(:choose_class_room, main_teacher),
           'student should be able to choose_class_room')
    assert(ability.can?(:choose_role, User))
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:subscribe_to_webinar, main_teacher))
    assert(ability.can?(:show, :account),
           'students should be able to access their account')

    assert(ability.can?(:index, ClassRoom))

    assert(ability.can?(:destroy, internship_application))
    assert(ability.can?(:update, internship_application))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.can?(:submit_internship_application, internship_application))
    assert(ability.can?(:validate_convention, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))

    assert(ability.can?(:see_tutor, InternshipOffer))

    assert(ability.can?(:manage_school_users, school))
    assert(ability.can?(:manage_school_students, school))
    assert(ability.can?(:choose_school, main_teacher),
           'student should be able to choose_school')
    assert(ability.can?(:manage_school_internship_agreements, school))
    assert(ability.cannot?(:create_remote_internship_request, school))

    assert(ability.cannot?(:manage_school_students, build(:school)))
    assert(ability.cannot?(%i[show edit update], School),
           'school_manager should be able manage school')
    assert(ability.cannot?(:manage_school_users, another_school))
    assert(ability.cannot?(:manage_school_students, another_school))
    refute(ability.can?(:sign_internship_agreements, internship_agreement.reload),
           'Ability : Signature should not be possible for teachers')
  end

  test 'Teacher' do
    school = create(:school, :with_school_manager)
    teacher = create(:teacher, school:)
    class_room = create(:class_room, school:)
    ability = Ability.new(teacher)

    assert(ability.can?(:subscribe_to_webinar, teacher))
    assert(ability.can?(:welcome_students, teacher),
           'teacher are to be able to welcome students')
    assert(ability.can?(:index, ClassRoom))
    assert(ability.can?(:see_tutor, InternshipOffer))
    assert(ability.can?(:manage_school_students, teacher.school))
    assert(ability.cannot?(:manage_school_students, build(:school)))
  end

  test 'Other' do
    school = create(:school, :with_school_manager)
    class_room = create(:class_room, school:)
    another_school = create(:school)
    other = create(:other, school:)
    ability = Ability.new(other)
    assert(ability.can?(:manage_school_students, other.school))
    assert(ability.cannot?(:manage_school_students, another_school))
    assert(ability.can?(:index, ClassRoom))
  end

  test 'Admin Offcer' do
    school = create(:school, :with_school_manager)
    class_room = create(:class_room, school:)
    another_school = create(:school)
    student = create(:student, school:)
    internship_application = create(:weekly_internship_application, student:)
    internship_agreement = create(:internship_agreement, internship_application:)
    admin_officer = create(:admin_officer, school:)
    ability = Ability.new(admin_officer)

    assert(ability.can?(:manage_school_students, admin_officer.school))
    assert(ability.cannot?(:manage_school_students, another_school))
    assert(ability.can?(:index, ClassRoom))
    assert(ability.can?(:read, InternshipAgreement))
  end

  test 'CPE' do
    school = create(:school, :with_school_manager)
    class_room = create(:class_room, school:)
    another_school = create(:school)
    class_room_2 = create(:class_room, school: another_school)

    cpe = create(:cpe, school:)
    ability = Ability.new(cpe)

    assert(ability.can?(:manage_school_students, cpe.school))
    assert(ability.cannot?(:manage_school_students, another_school))
    assert(ability.can?(:index, ClassRoom))
    assert(ability.cannot?(:change, class_room_2))
    assert(ability.can?(:read, InternshipAgreement))
  end

  test 'Operator' do
    operator = create(:user_operator)
    ability = Ability.new(operator)

    assert(ability.can?(:supply_offers, operator),
           'operator are to be able to supply offers')
    assert(ability.can?(:create, InternshipOffers::Api.new),
           'Operator should be able to create internship_offers')
    assert(ability.cannot?(:update, InternshipOffers::Api.new),
           'Operator should not be able to update internship offer not belonging to him')
    assert(ability.can?(:update, InternshipOffers::Api.new(employer: operator)),
           'Operator should be able to update internships offer that belongs to him')
    assert(ability.can?(:index_and_filter, Reporting::InternshipOffer))
    assert(ability.can?(:index, Acl::Reporting.new(user: operator, params: {})))
    assert(ability.can?(:index, Acl::InternshipOfferDashboard.new(user: operator)),
           'Operator should be able to index InternshipOfferDashboard')

    refute(ability.can?(:create_remote_internship_request, SupportTicket),
           'operators are not supposed to fill forms for remote internships support')
  end
end
