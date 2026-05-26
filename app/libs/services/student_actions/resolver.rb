module Services::StudentActions
  class Resolver
    def self.call(user_id:, urgency_levels:)
      urgency_levels = Array(urgency_levels)
      urgency_levels.each do |urgency_level|
        extra_resolver(user_id:, urgency_level:)
        standard_resolver(user_id:, urgency_level:)
      end
      MailActionItem.for_user(user_id)
                    .resolved
                    .delete_all
    end

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

        agreement_resolve(agreement) unless agreement.roles_not_signed_yet.include?("student")
      end
    end

    def self.standard_resolver(user_id:, urgency_level:)
      base = MailActionItem.for_user(user_id).where(urgency_level:)
      base.where("stale_at < ?", Time.current).delete_all
      base.where("deliveries_count >= max_deliveries_count").delete_all
    end

    def self.application_resolve(application)
      return unless application&.persisted?

      MailActionItem.where(
        action_type: :pending_internship_application,
        internship_application_id: application.id
      ).each { |item| item.update_columns(resolved_at: Time.current) }
    end

    def self.agreement_resolve(agreement)
      return unless agreement&.persisted?

      MailActionItem.where(
        action_type: :pending_internship_agreement,
        internship_agreement_id: agreement.id
      ).each { |item| item.update_columns(resolved_at: Time.current) }
    end
  end
end
