module InternshipAgreementSignaturable
  extend ActiveSupport::Concern

  included do
    def roles_not_signed_yet
      roles = [school_management_representative.role, 'employer'] 
      roles += ['student', 'student_legal_representative'] if Flipper.enabled?(:student_signature)
      roles - roles_already_signed
    end

    def signature_by_role(signatory_role:)
      return nil if signatures.blank?

      signatures.find_by(signatory_role:)
    end

    def roles_not_signed_yet_blank?
      roles_not_signed_yet.blank?
    end

    def roles_not_signed_yet_present?
      roles_not_signed_yet.present?
    end

    def signature_image_attached?(signatory_role:)
      signature = signature_by_role(signatory_role:)
      return signature.signature_image.attached? if signature && signature.signature_image

      false
    end

    def missing_signatures_recipients
      recipients = []
      
      if Flipper.enabled?(:student_signature, student)
        if roles_not_signed_yet.include?('student')
          recipients << student.email if student
        end
      else
        if (roles_not_signed_yet & Signature::SCHOOL_MANAGEMENT_SIGNATORY_ROLE).any?
          recipients << school_management_representative.email if school_management_representative
        end
        if roles_not_signed_yet.include?('employer')
          recipients << employer.email if employer
        end
      end
      recipients
    end

    def ready_to_sign?(user:)
      aasm_state.to_s.in?(%w[validated signatures_started]) && \
        !signed_by?(user:) && \
        user.can_sign?(self)
    end

    def signed_by?(user:)
      return false if user.nil?

      if user.employer_like? && user.team.alive?
        signatures.pluck(:user_id).any? { |userid| user.team.id_in_team?(userid) }
      else
        signatures.pluck(:user_id).include?(user.id)
      end
    end

    def signatory_roles
      signatures.pluck(:signatory_role)
    end

    # --- student
    def signed_by_student?
      return false if discarded?
      return false unless signatures.any?

      signatures.pluck(:signatory_role).include?('student')
    end

    def student_signature
      signature_by_role(signatory_role: 'student')
    end

    # --- school management
    def signed_by_school_management?
      school_management_signatory_role.present?
    end

    def school_management_signatory_role
      (signatory_roles & Signature::SCHOOL_MANAGEMENT_SIGNATORY_ROLE)&.first
    end
    # --- employer
    def signed_by_employer?
      return false if discarded?
      return false unless signatures.any?

      signatures.pluck(:signatory_role).include?('employer')
    end

    def signed_by_team_member?(user:)
      return false if user.nil?
      return signed_by?(user: user) if user.team.nil? || user.team.not_exists?

      user.team.db_members.any? { |member| signed_by?(user: member) }
    end

    # --- legal representative
    def signed_by_legal_representative?
      return false unless signatures.any?

      signatures.pluck(:signatory_role).include?('student_legal_representative')
    end

    def student_legal_representative_signature
      signed_by_legal_representative? && signature_by_role(signatory_role: 'student_legal_representative')
    end

    private

    def roles_already_signed
      Signature.where(internship_agreement_id: id)
               .pluck(:signatory_role)
    end
  end
end
