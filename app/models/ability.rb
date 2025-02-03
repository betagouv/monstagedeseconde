# frozen_string_literal: true

# list abilities for users
class Ability
  include CanCan::Ability

  def initialize(user = nil)
    if user.present?
      case user.type
      when 'Users::Student' then student_abilities(user:)
      when 'Users::Employer' then employer_abilities(user:)
      when 'Users::God' then god_abilities
      when 'Users::Operator' then operator_abilities(user:)
      when 'Users::PrefectureStatistician' then statistician_abilities(user:)
      when 'Users::EducationStatistician' then education_statistician_abilities(user:)
      when 'Users::MinistryStatistician' then ministry_statistician_abilities(user:)
      when 'Users::AcademyStatistician' then academy_statistician_abilities(user:)
      when 'Users::AcademyRegionStatistician' then academy_region_statistician_abilities(user:)
      when 'Users::SchoolManagement'
        common_school_management_abilities(user:)
        school_manager_abilities(user:) if user.school_manager?
        admin_officer_abilities(user:) if user.admin_officer?
      end

      shared_signed_in_user_abilities(user:)
    else
      visitor_abilities
    end
  end

  def visitor_abilities
    can %i[read apply], InternshipOffer
    can(:read_employer_name, InternshipOffer) do |internship_offer|
      read_employer_name?(internship_offer:)
    end
  end

  def god_abilities
    can :show, :account
    can :manage, School
    can :manage, Sector
    can :manage, Academy
    can :manage, AcademyRegion
    can %i[destroy see_tutor], InternshipOffer
    can %i[read update export unpublish publish], InternshipOffer
    can %i[read update destroy export], InternshipApplication
    can :manage, InternshipOfferKeyword
    can :manage, Group
    can :access, :rails_admin   # grant access to rails_admin
    can %i[read update delete discard export], InternshipOffers::Api
    can :read, :dashboard       # grant access to the dashboard
    can :read, :kpi # grant access to the dashboard
    can %i[index department_filter], Acl::Reporting do |_acl|
      true
    end
    can %i[index_and_filter], Reporting::InternshipOffer
    can :manage, InternshipAgreement
    can %i[ switch_user
            read
            update
            destroy
            export
            export_reporting_dashboard_data
            see_reporting_dashboard
            see_reporting_internship_offers
            see_reporting_schools
            see_reporting_associations
            see_reporting_enterprises
            see_dashboard_enterprises_summary
            see_dashboard_administrations_summary
            see_dashboard_associations_summary
            anonymize_user
            transform_user], User
    can :manage, Operator
    can :read_employer_name, InternshipOffer
  end

  def student_abilities(user:)
    can :look_for_offers, User
    can :resend_confirmation_phone_token, User do |user|
      user.phone.present? && user.student?
    end
    can :sign_with_sms, User
    can :show, :account
    can :change, ClassRoom do |class_room|
      class_room.school_id == user.school_id
    end
    can %i[read], InternshipOffer
    can %i[create delete], Favorite
    can :apply, InternshipOffer do |internship_offer|
      internship_offer.grades.include?(user.grade) &&
        !user.internship_applications.exists?(internship_offer_id: internship_offer.id) && # user has not already applied
        user.other_approved_applications_compatible?(internship_offer:) &&
        (!internship_offer.reserved_to_school? || internship_offer.school_id == user.school_id)
    end
    can %i[submit_internship_application update show internship_application_edit],
        InternshipApplication do |internship_application|
      internship_application.student.id == user.id
    end
    can(:read_employer_data, InternshipApplication) do |internship_application|
      internship_application.student.id == user.id &&
        (internship_application.approved? || internship_application.validated_by_employer?)
    end
    can(:cancel, InternshipApplication) do |internship_application|
      ok_canceling = %w[ submitted
                         read_by_employer
                         validated_by_employer
                         approved
                         convention_signed]
      user.student? && ok_canceling.include?(internship_application.aasm_state)
    end

    can %i[show
           update
           choose_school
           choose_class_room
           choose_gender_and_birthday
           register_with_phone], User
    can_read_dashboard_students_internship_applications(user:)
    can(:read_employer_name, InternshipOffer) do |internship_offer|
      read_employer_name?(internship_offer:)
    end
  end

  def admin_officer_abilities(user:)
    can :create, Signature do |signature|
      signature.internship_agreement.student.school == user.school
    end
  end

  def school_manager_abilities(user:)
    can %i[list_invitations
           create_invitation
           destroy_invitation], Invitation do |invitation|
      invitation.school.id == user.school_id
    end

    can_manage_school(user:) do
      can [:delete], User do |managed_user_from_school|
        managed_user_from_school.school_id == user.school_id
      end
    end
    can %i[
      read
      create
      edit
      sign_internship_agreements
      edit_activity_rating
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
      edit_student_birth_date
      edit_student_school
      edit_pai_project
      edit_pai_trousse_family
      see_intro
      update
    ], InternshipAgreement do |agreement|
      agreement.internship_application.student.school_id == user.school_id
    end
    can :create, Signature do |signature|
      signature.internship_agreement.school_manager == user.id
    end
  end

  def employer_abilities(user:)
    as_employers_like(user:)
    as_employers_signatory_abilities(user:)
    as_account_user(user:)
    can %i[sign_with_sms choose_function], User
  end

  def as_account_user(user:)
    can :show, :account
    can(:read_employer_name, InternshipOffer) do |internship_offer|
      read_employer_name?(internship_offer:)
    end
  end

  def as_employers_like(user:)
    can :subscribe_to_webinar, User do
      ENV.fetch('WEBINAR_URL', nil).present?
    end
    can :edit_password, User
    can_manage_teams(user:)
    can_manage_areas(user:)
    can %i[index], Acl::InternshipOfferDashboard
    can :supply_offers, User
    can :renew, InternshipOffer do |internship_offer|
      renewable?(internship_offer:, user:)
    end
    can :duplicate, InternshipOffer do |internship_offer|
      duplicable?(internship_offer:, user:)
    end
    can :publish, InternshipOffer do |internship_offer|
      internship_offer.employer_id == user.id &&
        internship_offer.last_date > SchoolYear::Current.new.beginning_of_period
    end
    can %i[create see_tutor], InternshipOffer
    can %i[read discard], InternshipOffer, employer_id: user.team_members_ids
    can %i[update], InternshipOffer do |internship_offer|
      internship_offer.employer_id.in?(user.team_members_ids) &&
        internship_offer.has_weeks_after_school_year_start?
    end
    can %i[create], InternshipOccupation
    can %i[create], Entreprise do |entreprise|
      entreprise.internship_occupation.employer_id == user.id
    end
    can %i[create], Planning do |planning|
      planning.entreprise.internship_occupation.employer_id == user.id
    end
    can %i[update edit renew], InternshipOccupation, employer_id: user.team_members_ids
    can %i[update edit renew], Entreprise do |entreprise|
      entreprise.internship_occupation.employer_id.in?(user.team_members_ids)
    end
    can %i[update edit renew], Planning do |planning|
      planning.entreprise.internship_occupation.employer_id.in?(user.team_members_ids)
    end
    can %i[index update_multiple], InternshipApplication do |internship_applications|
      internship_applications.all? do |internship_application|
        application_related_to_team?(user:, internship_application:)
      end
    end
    can(:read_employer_name, InternshipOffer) do |internship_offer|
      read_employer_name?(internship_offer:)
    end
    can %i[show transfer update], InternshipApplication do |internship_application|
      application_related_to_team?(user:, internship_application:)
    end
  end

  def as_employers_signatory_abilities(user:)
    can :create, InternshipAgreement
    can %i[
      read
      index
      edit
      update
      edit_organisation_representative_role
      edit_employer_name
      edit_employer_address
      edit_employer_contact_email
      edit_internship_address
      edit_tutor_email
      edit_tutor_role
      edit_activity_scope
      edit_skills_observe
      edit_skills_communicate
      edit_skills_understand
      edit_skills_motivation
      edit_activity_preparation
      edit_activity_learnings
      edit_date_range
      edit_organisation_representative_full_name
      edit_siret
      edit_tutor_full_name
      edit_weekly_hours
      edit_entreprise_address
      sign
      sign_internship_agreements
    ], InternshipAgreement do |agreement|
      agreement.employer.id.in?(user.team_members_ids)
    end
    can :create, Signature do |signature|
      signature.internship_agreement.internship_offer.internship_offer_area.employer_id.in?(user.team_members_ids)
    end
  end

  def can_manage_teams(user:)
    can %i[manage_teams], TeamMemberInvitation
    can %i[destroy], TeamMemberInvitation do |team_member_invitation|
      condition = if user.team.alive?
                    user.team.id_in_team?(team_member_invitation.member_id)
                  else
                    user == team_member_invitation.inviter_id
                  end
      team_member_invitation.member_id != user.id && condition
    end
  end

  def can_manage_areas(user:)
    can %i[create index], InternshipOfferArea

    can %i[update], InternshipOfferArea do |area|
      if user.team.alive?
        user.team.id_in_team?(area.employer_id)
      else
        user.id == area.employer_id
      end
    end

    can %i[destroy], InternshipOfferArea do |area|
      condition = if user.team.alive?
                    user.team.id_in_team?(area.employer_id)
                  else
                    user.id == area.employer_id
                  end
      user.team_areas.count > 1 && condition
    end

    can :generaly_destroy, InternshipOfferArea, user.team_areas.count > 1

    can :flip_notification, AreaNotification do |_area_notif|
      many_people_in_charge_of_area = !user.current_area.single_human_in_charge?
      current_area_notifications_are_off = !user.fetch_current_area_notification.notify

      user.team.alive? &&
        (many_people_in_charge_of_area || current_area_notifications_are_off)
    end

    can :manage_abilities, AreaNotification do |area_notification|
      user.team.alive? &&
        area_notification.internship_offer_area.employer_id.in?(user.team_members_ids)
    end
  end

  def operator_abilities(user:)
    as_account_user(user:)
    as_employers_like(user:)

    can :choose_operator, :sign_up
    can :change, :department
    can %i[update discard], InternshipOffers::Api, employer_id: user.team_members_ids
    can :create, InternshipOffers::Api
    can :show, :api_token
    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[index], Sector
    can %i[index], Acl::Reporting do |_acl|
      true
    end
    can %i[see_reporting_internship_offers
           export_reporting_dashboard_data
           see_reporting_schools
           see_reporting_enterprises
           check_his_statistics], User do
             !employers_only?
           end
    can :read_employer_name, InternshipOffer do |internship_offer|
      read_employer_name?(internship_offer:)
    end
  end

  def statistician_abilities(user:)
    common_to_all_statisticians(user:)

    can :show, :api_token

    can %i[create], InternshipOccupation

    can %i[index], Acl::Reporting, &:allowed?

    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[ see_reporting_dashboard
            see_dashboard_administrations_summary
            see_dashboard_department_summary
            export_reporting_dashboard_data
            see_dashboard_associations_summary
            export_reporting_school], User
    can :view, :department
  end

  def education_statistician_abilities(user:)
    common_to_all_statisticians(user:)
    can %i[create], InternshipOccupation
    can %i[index], Acl::Reporting, &:allowed?

    can %i[index_and_filter], Reporting::InternshipOffer
    can %i[ see_reporting_dashboard
            see_dashboard_administrations_summary
            see_dashboard_department_summary
            export_reporting_dashboard_data
            see_dashboard_associations_summary], User
    can :view, :department
  end

  def ministry_statistician_abilities(user:)
    common_to_all_statisticians(user:)

    can %i[create], InternshipOccupation do |internship_occupation|
      internship_occupation.group.in?(user.ministries) && internship_occupation.is_public
    end

    can %i[index_and_filter], Reporting::InternshipOffer
    can :read, Group
    can %i[index], Acl::Reporting, &:ministry_statistician_allowed?
    can %i[ export_reporting_dashboard_data
            see_ministry_dashboard
            see_dashboard_associations_summary ], User
  end

  def academy_statistician_abilities(user:)
    common_to_all_statisticians(user:)

    can %i[index_and_filter], Reporting::InternshipOffer
    can :read, Group
    can %i[index], Acl::Reporting # , &:allowed?
    can %i[ see_reporting_dashboard
            see_dashboard_administrations_summary
            see_dashboard_department_summary
            export_reporting_dashboard_data
            see_dashboard_associations_summary ], User
  end

  def academy_region_statistician_abilities(user:)
    common_to_all_statisticians(user:)

    can %i[index_and_filter], Reporting::InternshipOffer
    can :read, Group
    can %i[index], Acl::Reporting # , &:allowed?
    can %i[ export_reporting_dashboard_data
            see_dashboard_administrations_summary
            see_dashboard_department_summary
            export_reporting_dashboard_data
            see_dashboard_associations_summary ], User
  end

  def common_to_all_statisticians(user:)
    as_employers_like(user:)
    as_employers_signatory_abilities(user:) if user.agreement_signatorable?
    can %i[
      choose_statistician_type
      supply_offers
      subscribe_to_webinar
      choose_to_sign_agreements
    ], User

    can %i[see_reporting_dashboard
           see_dashboard_administrations_summary], User
  end

  def common_school_management_abilities(user:)
    can %i[list_invitations
           create_invitation
           destroy_invitation], Invitation do |invitation|
      invitation.school.id == user.school_id
    end

    can %i[
      welcome_students
      subscribe_to_webinar
      sign_with_sms
    ], User
    can :choose_role, User unless user.school_manager?
    can_create_and_manage_account(user:) do
      can [:choose_class_room], User
    end
    can_read_dashboard_students_internship_applications(user:)

    can :change, ClassRoom do |class_room|
      class_room.school_id == user.school_id && !user.school_manager?
    end

    can_manage_school(user:) do
      can %i[edit update], School
      can %i[manage_school_users
             manage_school_students
             manage_school_internship_agreements], School do |school|
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
      edit_activity_rating
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
      update
    ], InternshipAgreement do |agreement|
      agreement.internship_application.student.school_id == user.school_id
    end
  end

  private

  def can_read_dashboard_students_internship_applications(user:)
    can [:dashboard_index], Users::Student do |student|
      student.id == user.id || student_managed_by?(student:, user:)
    end

    can [:dashboard_show], InternshipApplication do |internship_application|
      internship_application.student.id == user.id ||
        student_managed_by?(student: internship_application.student, user:)
    end
  end

  def student_managed_by?(student:, user:)
    student.school_id == user.school_id &&
      user.is_a?(Users::SchoolManagement)
  end

  def shared_signed_in_user_abilities(user:)
    can :update, user
  end

  def can_create_and_manage_account(user:)
    can :show, :account
    can %i[show edit update], User
    can [:choose_school], :sign_up
    can :choose_school, User, id: user.id
    yield if block_given?
  end

  def can_manage_school(user:)
    can %i[
      show
      edit
      update
      create
      destroy
      manage_school_users
      index
    ], ClassRoom do |class_room|
      class_room.school_id == user.school_id
    end
    can :change, ClassRoom do |class_room|
      class_room.school_id == user.school_id && !user.school_manager?
    end

    can [:show_user_in_school], User do |user|
      user.school
          .users
          .map(&:id)
          .map(&:to_i)
          .include?(user.id.to_i)
    end
    yield if block_given?
  end

  def application_related_to_team?(user:, internship_application:)
    internship_application.internship_offer.employer_id == user.team_id
  end

  def offer_belongs_to_team?(user:, internship_offer:)
    internship_offer.employer_id == user.team_id
  end

  def renewable?(internship_offer:, user:)
    main_condition = internship_offer.persisted? &&
                     internship_offer.employer_id == user.id
    if main_condition
      school_year_start = SchoolYear::Current.new.beginning_of_period
      internship_offer.last_date <= school_year_start
    else
      false
    end
  end

  def duplicable?(internship_offer:, user:)
    internship_offer.persisted? &&
      internship_offer.employer_id == user.id
  end

  def read_employer_name?(internship_offer:)
    # this avoids the N+1 query issue
    if internship_offer.employer.type == 'Users::Operator'
      operator = internship_offer.employer.try(:operator)
      if operator.present? && operator.masked_data
        false
      elsif operator.present? && operator.departments.any?
        !internship_offer.zipcode[0..1].in?(operator.departments.map(&:code))
      else
        true
      end
    else
      true
    end
  end

  def employers_only?
    ENV.fetch('EMPLOYERS_ONLY', 'false') == 'true'
  end
end
