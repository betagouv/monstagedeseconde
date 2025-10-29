module InternshipAgreements
  class SignatureStatusComponent < BaseComponent
    attr_reader :internship_agreement, :current_user, :label, :second_label

    def initialize(internship_agreement:)
      @internship_agreement = internship_agreement
    end

    def employer_info
      user_info(signatory_role: 'employer')
    end

    def school_manager_info
      Signature::SCHOOL_MANAGEMENT_SIGNATORY_ROLE.each do |role|
        actor_signed = @internship_agreement.signatures.pluck(:signatory_role).include?(role)
        if actor_signed
          color = 'green'
          icon = 'fr-icon-check-line'
          return {icon: icon, color: color, actor_signed: actor_signed}
        end
      end
      color = 'grey'
      icon = 'fr-icon-close-line'
      {icon: icon, color: color, actor_signed: false}
    end

    def student_info
      user_info(signatory_role: 'student')
    end

    def legal_representative_info
      user_info(signatory_role: 'student_legal_representative')
    end

    def user_info(signatory_role:)
      actor_signed = @internship_agreement.signatures.pluck(:signatory_role).include?(signatory_role)
      color = actor_signed ? 'green' : 'grey'
      icon = actor_signed ? 'fr-icon-check-line' : 'fr-icon-close-line'
      {icon: icon, color: color, actor_signed: actor_signed}
    end
  end
end
