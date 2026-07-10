module ReviewRebuild
  module AgreementsCreationSteps
    extend ActiveSupport::Concern

    def create_agreements
      InternshipApplication.approved.each do |application|
        iag_builder = Builders::InternshipAgreementBuilder.new(user: Users::God.first)
        iag = iag_builder.new_from_application(application)
        iag.skip_notifications_when_system_creation = true
        info(iag.errors.full_messages.to_sentence) unless iag.valid?
        iag.student_legal_representative_full_name = 'Lise Collado'
        iag.student_legal_representative_email = 'lise.collado@orange.fr'
        iag.student_legal_representative_2_full_name = 'Frédéric Tolenado'
        iag.student_legal_representative_2_email = 'frederic.tolenado@free.fr'
        iag.save! if iag.valid?
      end

      internship_agreements = InternshipAgreement.all.to_a
      internship_agreements.select { |iag| iag.draft? }[0..-2].each do |iag|
        iag.complete!
        iag.start_by_school_manager!
        iag.finalize!
      end

      # signatures_started — élève et représentant légal ont signé (3ème)
      agreement = InternshipAgreement.validated.troisieme_grades.first
      if agreement.present?
        Signature.new(student_attributes(agreement, 'student')).save!
        agreement.sign!
        Signature.new(student_attributes(agreement, 'student_legal_representative')).save!
        agreement.sign!
      end

      # signatures_started — élève et représentant légal ont signé (2de)
      agreement = InternshipAgreement.validated.seconde_grades.first
      if agreement.present?
        Signature.new(student_attributes(agreement, 'student')).save!
        agreement.sign!
        Signature.new(student_attributes(agreement, 'student_legal_representative')).save!
        agreement.sign!
      end
    end

    def student_attributes(agreement, signatory_role)
      {
        signatory_role:  signatory_role,
        signature_date:  Time.current,
        signatory_ip:    FFaker::Internet.ip_v4_address,
        internship_agreement: agreement,
        user_id:         agreement.student.id
      }
    end
  end
end
