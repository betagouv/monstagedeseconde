# frozen_string_literal: true

module Presenters
  class InternshipApplication
    class HumanState
      UnknownRole  = Class.new(StandardError)
      UnknownState = Class.new(StandardError)

      ROLES = %i[student school_management employer].freeze

      def self.for(application:, role:, application_path:)
        new(application:, role:, application_path:)
      end

      def to_h
        state_method = :"state_#{@application.aasm_state}"
        raise UnknownState, @application.aasm_state unless respond_to?(state_method, true)

        send(state_method)
      end

      def [](key) = to_h[key]

      private

      attr_reader :application, :role, :application_path

      def initialize(application:, role:, application_path:)
        raise UnknownRole, role unless ROLES.include?(role)

        @application      = application
        @role             = role
        @application_path = application_path
      end

      def student?           = role == :student
      def school_management? = role == :school_management
      def employer?          = role == :employer
      def student_or_school? = student? || school_management?

      def action(label:, level:)
        { path: application_path, label:, level: }
      end

      def state_submitted
        { label:   student_or_school? ? "Sans réponse de l'entreprise" : "nouveau",
          badge:   "info",
          tab:     student? ? "Envoyées, en attente de réponse" : "Reçues, en attente de réponse",
          actions: [ action(label: student? ? "Voir" : "Répondre",
                           level: student? ? "tertiary" : "primary") ] }
      end

      def state_restored
        previously_progressed = application.has_ever_been?(%w[read_by_employer transfered validated_by_employer])
        { label:   if student? then "sans réponse de l'entreprise"
                   elsif previously_progressed then "candidature restaurée"
                   else "nouveau"
                   end,
          badge:   "info",
          tab:     student? ? "Envoyées, en attente de réponse" : "Reçues, en attente de réponse",
          actions: [ action(label: if student? then "Voir"
                                   elsif previously_progressed then "Candidature restaurée - répondre"
                                   else "Répondre"
                                   end,
                           level: student? ? "tertiary" : "primary") ] }
      end

      def state_read_by_employer
        { label:   student_or_school? ? "Sans réponse de l'entreprise" : "Lue",
          badge:   student? ? "info" : "warning",
          tab:     student? ? "Envoyées, en attente de réponse" : "Reçues, en attente de réponse",
          actions: [ action(label: student_or_school? ? "Voir" : "Répondre",
                           level: student? ? "tertiary" : "primary") ] }
      end

      def state_transfered
        { label:   student? ? "en attente de réponse" : "transféré",
          badge:   "info",
          tab:     student? ? "Envoyées, en attente de réponse" : "Transférées",
          actions: [ action(label: student? ? "en attente de réponse" : "transféré",
                           level: student? ? "tertiary" : "primary") ] }
      end

      def state_validated_by_employer
        { label:   student_or_school? ? "acceptée par l'entreprise" : "en attente de réponse",
          badge:   student? ? "success" : "info",
          tab:     "Acceptées par l’offreur, à confirmer par l’élève",
          actions: [ action(label: student? ? "Répondre" : "Voir",
                           level: student? ? "primary" : "tertiary") ] }
      end

      def state_canceled_by_employer
        { label:   "annulée par l'employeur",
          badge:   "error",
          tab:     "Annulées",
          actions: [ action(label: "Voir", level: "tertiary") ] }
      end

      def state_rejected
        { label:   "refusée par l'employeur",
          badge:   "warning",
          tab:     "Refusées",
          actions: [ action(label: "Voir", level: "tertiary") ] }
      end

      def state_canceled_by_student
        { label:   student_or_school? ? "annulée" : "annulée par l'élève",
          badge:   "purple-glycine",
          tab:     "Annulées",
          actions: [ action(label: "Voir", level: "tertiary") ] }
      end

      def state_expired
        { label:   "expirée",
          badge:   "error",
          tab:     "Expirées",
          actions: [ action(label: "Voir", level: "tertiary") ] }
      end

      def state_expired_by_student
        { label:   student_or_school? ? "vous n'avez pas répondu dans les délais" : "l'élève n'a pas répondu dans les délais",
          badge:   "error",
          tab:     "Expirées",
          actions: [ action(label: "Voir", level: "tertiary") ] }
      end

      def state_canceled_by_student_confirmation
        { label:   student? ? "Vous avez choisi un autre stage" : "L'élève a choisi un autre stage",
          badge:   "purple-glycine",
          actions: [ action(label: "Voir", level: "tertiary") ] }
      end

      def state_approved
        { label:   "stage validé",
          badge:   "success",
          tab:     student? ? "Votre stage validé" : "Stage validé",
          actions: [ action(label: student? ? "Contacter l'employeur" : "Voir",
                           level: student? ? "primary" : "secondary") ] }
      end
    end
  end
end
