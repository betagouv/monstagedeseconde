module Presenters
  class InternshipAgreement
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    delegate :signature_started?,  to: :internship_agreement
    delegate :signed_by?,  to: :internship_agreement
    delegate :signed_by_team_member?,  to: :internship_agreement
    delegate :internship_application, to: :internship_agreement

    delegate :student, to: :internship_application
    delegate :internship_offer, to: :internship_application
    delegate :title, to: :internship_offer, prefix: true
    delegate :employer_name, to: :internship_offer
    delegate :period, to: :internship_offer
    delegate :canceled_by_employer_message, to: :internship_application
    delegate :rejected_message, to: :internship_application

    def student_name
      student.name
    end

    def internship_agreement
      @internship_agreement
    end

    def internship_offer_title
      internship_offer.title
    end

    def internship_offer_address
      internship_offer.presenter.address || 'Adresse non renseignée'
    end

    def str_weeks
      WeekList.new(weeks: internship_application.weeks).to_s
    end

    def employer_name
      if internship_offer.from_multi?
        internship_offer.corporations
                        .pluck(:corporation_name)
                        .map { |name| name.truncate(20) }
                        .join(' | ')
                        .truncate(100)
      else
        internship_offer.employer_name
      end
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

    def signed_by_student?
      ::Signature.where(
        internship_agreement_id: internship_agreement.id,
        user_id: reader.id,
        signatory_role: 'student'
      ).exists?
    end

    def human_state
      # label stands for badge content
      # action_label stands for action button content
      action_path = { path: internship_agreement_path }
      case internship_agreement.aasm_state.to_s
      when 'validated'
        { label: "en attente de signatures",
          button_type: '',
          badge: 'info',
          actions: []}# [action_path.merge(label: action_label, level: action_level)] }
      when 'signatures_started'
        { label: "partiellement signée",
          button_type: 'fr-btn--secondary',
          badge: 'info',
          actions: []}
      when 'signed_by_all'
        { label: "signée de tous",
          button_type: 'fr-btn--secondary',
          badge: 'success',
          actions: []}
      else
        {}
      end
    end

    def human_multi_state(corporation_id:)
      corporation_internship_agreement = CorporationInternshipAgreement.find_by(
        internship_agreement_id: internship_agreement.id,
        corporation_id: corporation_id
      )
      if corporation_internship_agreement.nil?
        {status: "N/A",
        to_be_signed: false}
      elsif corporation_internship_agreement.signed
        { status: "Signée",
          to_be_signed: false}
      else
        { status: "En attente de signature",
         to_be_signed: true}
      end
    end

    def corporations_info
      internship_offer.corporations.tap do |corporations|
        corporations_signed_ids = corporations.map{|c| c.corporation_internship_agreement_for(internship_agreement)}
                                              .select(&:signed)
                                              .map(&:corporation_id)
        signed_count = corporations_signed_ids.count
        total_count = corporations.count

        return {
          signed_count: signed_count,
          total_count: total_count,
          signed_corporations_ids: corporations_signed_ids,
          corporations: corporations.map { |corporation| corporation_info(corporation) }
        }
      end
    end

    def corporation_info(corporation)
      cia = corporation.corporation_internship_agreement_for(internship_agreement)
      {
        corporation_name: corporation.corporation_name,
        signed: cia.signed,
        employer_name: corporation.employer_name,
        employer_email: corporation.employer_email,
        icon: cia.signed ? 'fr-badge--success' : 'fr-badge--warning',
        label: cia.signed ? 'Signée' : 'En attente'
      }
    end

    attr_reader :internship_agreement,
                :internship_application,
                :internship_offer,
                :school_manager,
                :school,
                :employer,
                :student,
                :internship_offer,
                :current_user,
                :reader
    protected




    def initialize(internship_agreement, current_user)
      @internship_agreement = internship_agreement
      @internship_application = internship_agreement.internship_application
      @current_user = current_user
      @student = internship_agreement.internship_application.student
      @school_manager = internship_agreement.try(:school_manager)
      @school = @student&.school
      @employer = internship_agreement.employer
      @internship_offer = internship_agreement.internship_application.internship_offer
      @reader = current_user
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

    def internship_agreement_path
      Rails.application.routes.url_helpers.dashboard_internship_agreement_path(
        uuid: internship_agreement.uuid
      )
    end
  end
end