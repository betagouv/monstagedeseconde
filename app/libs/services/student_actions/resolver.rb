module Services::StudentActions
  class Resolver < ::Services::CommonActions::BaseResolver
    def self.extra_resolver(user_id:, urgency_level:)
      base = MailActionItem.for_user(user_id).where(urgency_level:)

      # ---------------------------------------------------
      # internship_application_rejected: resolve if application is no longer rejected
      # ---------------------------------------------------
      base.where(action_name: "internship_application_rejected").each do |item|
        unless item.internship_application&.rejected?
          application_resolve(item.internship_application)
        end
      end

      # ---------------------------------------------------
      # internship_application_validated_by_employer:
      # resolve if application is no longer waiting for student approval
      # ---------------------------------------------------
      base.where(action_name: "internship_application_validated_by_employer").each do |item|
        unless item.internship_application&.validated_by_employer?
          application_resolve(item.internship_application)
        end
      end

      # ---------------------------------------------------
      # internship_application_expired: resolve if application is no longer expired
      # ---------------------------------------------------
      base.where(action_name: "internship_application_expired").each do |item|
        unless item.internship_application&.expired?
          application_resolve(item.internship_application)
        end
      end

      # ---------------------------------------------------
      # agreement_to_sign: resolve once student has signed
      # ---------------------------------------------------
      base.where(action_name: "agreement_to_sign").each do |item|
        agreement = item.internship_agreement
        next if agreement.nil?

        unless agreement.roles_not_signed_yet.include?("student")
          agreement_resolve(agreement, exclude_action_names: [ "agreement_signed_by_all" ])
        end
      end
    end

    def self.application_resolve(application)
      return unless application&.persisted?

      MailActionItem.where(
        action_type: :pending_internship_application,
        internship_application_id: application.id
      ).each { |item| item.update_columns(resolved_at: Time.current) }
    end

    def self.agreement_resolve(agreement, exclude_action_names: [])
      return unless agreement&.persisted?

      query = MailActionItem.where(
        action_type: :pending_internship_agreement,
        internship_agreement_id: agreement.id
      )
      query = query.where.not(action_name: exclude_action_names) if exclude_action_names.any?
      query.each { |item| item.update_columns(resolved_at: Time.current) }
    end
  end
end
