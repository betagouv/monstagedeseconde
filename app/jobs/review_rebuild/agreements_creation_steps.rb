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
      internship_agreements.select{ |iag| iag.validated? }[0..-2].each do |iag|
        iag.complete!
        iag.start_by_school_manager!
        iag.finalize!
      end

      agreement = InternshipAgreement.validated.troisieme_grades.first
      Signature.new(common_attributes(agreement, 'school_manager'))
               .save!
      agreement.sign!

      # agreement = InternshipAgreement.validated.troisieme_grades.second
      # Signature.new(common_attributes(agreement, 'employer'))
      #          .save!
      # agreement.sign!

      agreement = InternshipAgreement.validated.seconde_grades.first
      Signature.new(common_attributes(agreement, 'school_manager'))
               .save!
      agreement.sign!

      # agreement = InternshipAgreement.validated.seconde_grades.second
      # Signature.new(common_attributes(agreement, 'employer'))
      #          .save!
      # agreement.sign!
      
      Signature.new(common_attributes(agreement, 'student_legal_representative'))
               .save!
      agreement.sign!

      # --- pair signing
      # agreement = InternshipAgreement.validated.seconde_grades.third
      # Signature.new(common_attributes(agreement, 'school_manager'))
      #          .save!
      # agreement.sign!

      # Signature.new(common_attributes(agreement, 'employer'))
      #          .save!
      # agreement.sign!

      # Signature.new(common_attributes(agreement, 'student'))
      #          .save!
      # agreement.sign!
    end

    def common_attributes(agreement, signatory_role)
      hash = {
        signature_image: Rack::Test::UploadedFile.new('test/fixtures/files/signature.png', 'image/png'),
        signature_date: Time.current,
        signatory_ip: FFaker::Internet.ip_v4_address,
        signature_phone_number: '+33123456789',
        internship_agreement: agreement
      }
      hash[:signatory_role] = signatory_role
      hash[:user_id] = if signatory_role == 'school_manager'
                         agreement.school_manager.id
                       elsif signatory_role == 'employer'
                         agreement.employer.id
                       elsif signatory_role == 'student'
                         agreement.student.id
                       elsif signatory_role == 'student_legal_representative'
                         agreement.student.id
                       end
      hash
    end
  end
end
