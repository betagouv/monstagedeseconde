# frozen_string_literal: true

module Abilities
  module StudentAbility
    def student_abilities(user:)
      can %i[look_for_offers sign_with_sms], User
      can :resend_confirmation_phone_token, User do |user|
        user.phone.present? && user.student?
      end
      can :show, :account
      can %i[read], InternshipOffer
      can %i[create delete], Favorite
      can :share, InternshipOffer
      can :apply, InternshipOffer do |internship_offer|
        internship_offer.grades.include?(user.grade) &&
          !(user.grade == Grade.troisieme && user.internship_applications.exists?(aasm_state: "approved")) &&
          (!user.internship_applications.exists?(internship_offer_id: internship_offer.id) ||
          existing_application(internship_offer, user)&.canceled_with_passed_approved_application?) &&
          user.other_approved_applications_compatible?(internship_offer:) &&
          internship_offer.published? &&
          !internship_offer.from_api? &&
          (!internship_offer.reserved_to_schools? || user.school_id.in?(internship_offer.schools.pluck(:id))) &&
          (!internship_offer.rep  || user.school.rep_or_rep_plus?) &&
          (!internship_offer.qpv || user.school.qpv?)
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
                           restored
                           read_by_employer
                           validated_by_employer
                           approved
                           convention_signed]
        user.student? && ok_canceling.include?(internship_application.aasm_state)
      end

      can %i[show
             update
             register_with_phone], User
      can_read_dashboard_students_internship_applications(user:)
      can(:read_employer_name, InternshipOffer) do |internship_offer|
        read_employer_name?(internship_offer:)
      end
      can(:restore, InternshipApplication) do |internship_application|
        internship_application.student.id == user.id &&
          !internship_application.student.has_found_her_internships? &&
          internship_application.aasm_state.in?(InternshipApplication::RESTORABLE_STATES) &&
          internship_application.restored_at.nil? &&
          internship_application.no_weeks_overlap?
      end

      can %i[read
           show
           sign
           student_sign
           legal_representative_sign
           relaunch_legal_representative_sign_email], InternshipAgreement do |internship_agreement|
        internship_agreement.student.id == user.id
      end

      can %i[manage, update], InappropriateOffer
      can :show_internship_agreement, User do |user|
        user.currently_signing_internship_agreement?
      end
    end

    private

    def existing_application(internship_offer, user)
      user.internship_applications.find_by(internship_offer_id: internship_offer.id)
    end
  end
end
