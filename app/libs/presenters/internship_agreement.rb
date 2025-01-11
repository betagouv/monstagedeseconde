module Presenters
  class InternshipAgreement
    delegate :signature_started?,  to: :internship_agreement
    delegate :signed_by?,  to: :internship_agreement
    delegate :signed_by_team_member?,  to: :internship_agreement

    def student_name
      student.name
    end

    def internship_offer_title
      internship_offer.title
    end

    def employer_name
      internship_offer.employer_name
    end

    def role
      return 'employer' if current_user.employer_like?
      return 'school_manager' if current_user.school_management?

      nil
    end

    def translation_path(role)
      "activerecord.attributes.internship_agreement.status.#{role}.#{internship_agreement.aasm_state}"
    end

    def status_label
      translation_path = translation_path(role)
      common_status_label(translation_path)
    end

    def inline_status_label
      translation_path = translation_path(current_user.role || 'employer')
      common_status_label(translation_path)
    end

    protected

    attr_reader :internship_agreement,
                :school_manager,
                :school,
                :employer,
                :student,
                :internship_offer,
                :current_user

    def initialize(internship_agreement, current_user)
      @internship_agreement = internship_agreement
      @current_user = current_user
      @student = internship_agreement.internship_application.student
      @school_manager = internship_agreement.try(:school_manager)
      @school = @student&.school
      @employer = internship_agreement.employer
      @internship_offer = internship_agreement.internship_application.internship_offer
    end

    def common_status_label(translation_path)
      if internship_agreement.signatures_started? &&
          (internship_agreement.signed_by_team_member?(user: current_user) ||
            internship_agreement.signed_by?(user: current_user.try(:school).try(:school_manager)))
        I18n.t("#{translation_path}.already_signed")
      elsif internship_agreement.signatures_started?
        I18n.t("#{translation_path}.not_signed_yet")
      else
        I18n.t(translation_path)
      end
    end
  end
end