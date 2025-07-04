module Presenters
  class InternshipApplication
    include ::ActionView::Helpers::DateHelper

    delegate :student, to: :internship_application
    delegate :internship_offer, to: :internship_application
    delegate :title, to: :internship_offer, prefix: true
    delegate :employer_name, to: :internship_offer
    delegate :period, to: :internship_offer
    delegate :canceled_by_employer_message, to: :internship_application
    delegate :rejected_message, to: :internship_application

    SUBMITTED_LIKE_STATES = %w[submitted
                               restored
                               read_by_employer
                               transfered].freeze

    def expires_in
      start = internship_application.updated_at
      finish = start + ::InternshipApplication::EXPIRATION_DURATION
      distance_of_time_in_words_to_now(finish, include_days: true)
    end

    def internship_offer_address
      internship_application.internship_offer
                            .presenter
                            .address
    end

    def internship_offer_title
      internship_offer.title
    end

    def human_state
      # label stands for badge content
      # action_label stands for action button content
      action_path = { path: internship_application_path }
      case internship_application.aasm_state.to_s
      when 'submitted'
        label = reader.student? || reader.school_management? ? "Sans réponse de l'entreprise" : 'nouveau'
        action_label = reader.student? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        tab = reader.student? ? 'Envoyées, en attente de réponse' : 'Reçues, en attente de réponse'
        { label:,
          badge: 'info',
          tab:,
          actions: [action_path.merge(label: action_label, level: action_level)] }
      when 'restored'
        states_with_notice = %w[read_by_employer transfered validated_by_employer]
        action_label = if reader.student?
                         'Voir'
                       elsif internship_application.has_ever_been?(states_with_notice)
                         'Candidature restaurée - répondre'
                       else
                         'Répondre'
                       end
        label = if reader.student?
                  "sans réponse de l'entreprise"
                elsif internship_application.has_ever_been?(states_with_notice)
                  'candidature restaurée'
                else
                  'nouveau'
                end
        action_level = reader.student? ? 'tertiary' : 'primary'
        tab = reader.student? ? 'Envoyées, en attente de réponse' : 'Reçues, en attente de réponse'
        { label:,
          badge: 'info',
          tab:,
          actions: [action_path.merge(label: action_label, level: action_level)] }
      when 'read_by_employer'
        label = reader.student? || reader.school_management? ? "Sans réponse de l'entreprise" : 'Lue'
        badge = reader.student? ? 'info' : 'warning'
        tab = reader.student? ? 'Envoyées, en attente de réponse' : 'Reçues, en attente de réponse'
        action_label = reader.student? || reader.school_management? ? 'Voir' : 'Répondre'
        action_level = reader.student? ? 'tertiary' : 'primary'
        { label:,
          badge:,
          tab:,
          actions: [action_path.merge(label: action_label, level: action_level)] }

      when 'transfered'
        action_label = reader.student? ? 'en attente de réponse' : 'transféré'
        action_level = reader.student? ? 'tertiary' : 'primary'
        label = reader.student? ? 'en attente de réponse' : 'transféré'
        tab = reader.student? ? 'Envoyées, en attente de réponse' : 'Transférées'
        { label:,
          badge: 'info',
          tab:,
          actions: [action_path.merge(label: action_label, level: action_level)] }

      when 'validated_by_employer'
        label = reader.student? || reader.school_management? ? 'acceptée par l\'entreprise' : 'en attente de réponse'
        action_label = reader.student? ? 'Répondre' : 'Voir'
        action_level = reader.student? ? 'primary' : 'tertiary'
        badge = reader.student? ? 'success' : 'info'
        tab = 'Acceptées par l’offreur, à confirmer par l’élève'
        { label:,
          badge:,
          tab:,
          actions: [action_path.merge(label: action_label, level: action_level)] }
      when 'canceled_by_employer'
        # label = reader.student? || reader.school_management? ? 'annulée par l\'entreprise' : 'refusée'
        tab = 'Annulées'
        { label: 'annulée par l\'employeur',
          badge: 'error',
          tab:,
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')] }
      when 'rejected'
        # label = reader.student? || reader.school_management? ? 'refusée par l\'entreprise' : 'refusée'
        tab = 'Refusées'
        { label: 'refusée par l\'employeur',
          badge: 'warning',
          tab:,
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')] }
      when 'canceled_by_student'
        label = reader.student? || reader.school_management? ? 'annulée' : 'annulée par l\'élève'
        tab = 'Annulées'
        { label:,
          badge: 'purple-glycine',
          tab:,
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')] }
      when 'expired'
        { label: 'expirée',
          badge: 'error',
          tab: 'Expirées',
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')] }
      when 'canceled_by_student_confirmation'
        { label: reader.student? ? 'Vous avez choisi un autre stage' : "L'élève a choisi un autre stage",
          badge: 'purple-glycine',
          actions: [action_path.merge(label: 'Voir', level: 'tertiary')] }
      when 'approved'
        action_label = reader.student? ? 'Contacter l\'employeur' : 'Voir'
        action_level = reader.student? ? 'primary' : 'secondary'
        tab = reader.student? ? 'Votre stage validé' : 'Stage validé'
        { label: 'stage validé',
          badge: 'success',
          tab:,
          actions: [action_path.merge(label: action_label, level: action_level)] }
      else
        {}
      end
    end

    def actions_in_show_page
      return '' if internship_application.aasm_state.nil?

      student_has_found = internship_application.student
                                                .with_2_weeks_internships_approved?
      student_has_found ? actions_when_student_has_found : actions_when_student_has_not_found
    end

    def actions_when_student_has_found
      return [] unless internship_application.approved?

      [{ label: 'Contacter l\'offreur',
         color: 'primary',
         level: 'tertiary' }]
    end

    def actions_when_student_has_not_found
      case internship_application.aasm_state
      when 'submitted'
        [{ label: 'Renvoyer la demande',
           color: 'primary',
           level: 'primary' }]

      when 'transfered'
        [{ label: 'Renvoyer la demande',
           color: 'primary',
           level: 'primary' }]

      when 'read_by_employer'
        [{ label: 'Renvoyer la demande',
           color: 'primary',
           level: 'tertiary' }]

      when 'validated_by_employer'
        [{ label: 'Choisir ce stage',
           form_path: internship_application_path,
           transition: 'approve!',
           color: 'primary',
           level: 'primary' }]
      when 'approved'
        [{ label: 'Contacter l\'offreur',
           color: 'primary',
           level: 'tertiary' }]

      when 'canceled_by_employer', 'rejected', 'canceled_by_student', 'expired', 'canceled_by_student_confirmation'
        []

      else
        []
      end
    end

    def ok_for_transfer?
      current_state_in_list?(ok_for_transfer_states)
    end

    def ok_for_reject?
      internship_application.rejectable?
    end

    def ok_for_employer_validation?
      current_state_in_list?(SUBMITTED_LIKE_STATES)
    end

    def with_employer_explanation?
      unless internship_application.aasm_state.in?(::InternshipApplication.with_employer_explanations_states)
        return false
      end

      explanation_count.positive?
    end

    def explanation_count
      count = 0
      count += 1 if internship_application.canceled_by_employer_message?
      count += 1 if internship_application.rejected_message?
      count
    end

    def employer_explanations
      motives = []
      canceled_motive = { meth: :canceled_by_employer_message, label: 'Annulation par l\'entreprise' }
      rejected_motive = { meth: :rejected_message, label: 'Refus par l\'entreprise' }

      motives << canceled_motive if internship_application.canceled_by_employer_message?
      motives << rejected_motive if internship_application.rejected_message?

      motives.map do |motive|
        text = internship_application.send(motive[:meth].to_s)
        text.blank? ? nil : "<p><strong>#{motive[:label]}</strong> : </br>#{text}"
      end.compact
    end

    def str_weeks
      WeekList.new(weeks:).to_s
    end

    attr_reader :internship_application,
                :student,
                :internship_offer,
                :reader,
                :weeks

    protected

    def initialize(internship_application, user)
      @reader = user
      @internship_application = internship_application
      @student                = internship_application.student
      @internship_offer       = internship_application.internship_offer
      @weeks                  = internship_application.weeks
    end

    def rails_routes
      Rails.application.routes.url_helpers
    end

    def internship_application_path
      rails_routes.dashboard_students_internship_application_path(
        student_id: internship_application.user_id,
        uuid: internship_application.uuid
      )
    end

    def edit_internship_application_path
      rails_routes.edit_dashboard_students_internship_application_path(
        student_id: internship_application.user_id,
        uuid: internship_application.uuid
      )
    end

    private

    def current_state_in_list?(state_array)
      state_array.include?(internship_application.aasm_state)
    end

    def ok_for_transfer_states
      %w[submitted restored read_by_employer]
    end
  end
end
