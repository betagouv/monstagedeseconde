# frozen_string_literal: true

module Abilities
  module SchoolManagementAbility
    def school_manager_abilities(user:)
      can %i[list_invitations
             destroy_invitation], Invitation do |invitation|
        invitation.school.id == user.school_id
      end

      can_manage_school(user:) do
        can [ :delete ], User do |managed_user_from_school|
          managed_user_from_school.school_id == user.school_id
        end
      end
      can %i[
        read
        create
        edit
        edit_financial_conditions_rich_text
        edit_legal_terms_rich_text
        edit_school_representative_full_name
        edit_school_representative_phone
        edit_school_representative_email
        edit_school_representative_role
        edit_delegation_date
        edit_legal_status
        edit_student_refering_teacher_full_name
        edit_student_refering_teacher_email
        edit_student_refering_teacher_phone
        edit_student_address
        edit_student_full_name
        edit_student_phone
        edit_student_legal_representative_email
        edit_student_legal_representative_full_name
        edit_student_legal_representative_phone
        edit_student_legal_representative_2_email
        edit_student_legal_representative_2_full_name
        edit_student_legal_representative_2_phone
        edit_student_birth_date
        edit_student_school
        edit_pai_project
        edit_pai_trousse_family
        see_intro
        show
        update
      ], InternshipAgreement do |agreement|
        agreement.internship_application.student.school_id == user.school_id
      end
      can :create, Signature do |signature|
        signature.internship_agreement.school_manager == user.id
      end
    end

    def common_school_management_abilities(user:)
      can :show_modal_info, User
      can %i[list_invitations
             destroy_invitation], Invitation do |invitation|
        invitation.school.id == user.school_id
      end
      can %i[create_invitation], Invitation do |invitation|
        invitation.school.id == user.school_id &&
          (user.school_manager? || user.admin_officer?)
      end

      can %i[
        welcome_students
        subscribe_to_webinar
        sign_with_sms
      ], User
      can :choose_role, User unless user.school_manager?
      can_create_and_manage_account(user:) do
        can [ :choose_class_room ], User
      end
      can_read_dashboard_students_internship_applications(user:)

      can_manage_school(user:) do
        can %i[edit update], School do |school|
          school.id == user.school_id
        end
        can %i[manage_school_users
               manage_school_students
               manage_school_internship_agreements
               edit_signature
               update_signature], School do |school|
          school.id == user.school_id
        end
      end
      can %i[submit_internship_application validate_convention],
          InternshipApplication do |internship_application|
        internship_application.student.school_id == user.school_id
      end
      can %i[update destroy], InternshipApplication do |internship_application|
        user.school
            .students
            .where(id: internship_application.student.id)
            .count
            .positive?
      end
      can %i[see_tutor], InternshipOffer
      can(:read_employer_name, InternshipOffer) do |internship_offer|
        read_employer_name?(internship_offer:)
      end
      can %i[
        read
        create
        edit
        edit_financial_conditions_rich_text
        edit_legal_terms_rich_text
        edit_school_representative_full_name
        edit_school_representative_phone
        edit_school_representative_email
        edit_school_representative_role
        edit_delegation_date
        edit_legal_status
        edit_student_refering_teacher_full_name
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
        show
        update
      ], InternshipAgreement do |agreement|
        agreement.internship_application.student.school_id == user.school_id
      end
      can :sign_internship_agreements, InternshipAgreement do |agreement|
        agreement.internship_application.student.school_id == user.school_id &&
          (agreement.validated? || (agreement.signatures_started? && !agreement.signed_by_school_management?))
      end
      can :create, Signature do |signature|
        signature.internship_agreement.student.school.id == user.school.id
      end
    end
  end
end
