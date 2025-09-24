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
      user_info(signatory_role: 'school_manager')
    end

    def student_info
      user_info(signatory_role: 'student')
    end

    def legal_representative_info
      user_info(signatory_role: 'legal_representative')
    end

    def user_info(signatory_role:)
      employer_signed = @internship_agreement.signatures.pluck(:signatory_role).include?(signatory_role)
      color = employer_signed ? 'green' : 'grey'
      icon = employer_signed ? 'fr-icon-check-line' : 'fr-icon-close-line'
      {icon: icon, color: color}
    end
  end
end
