module ReviewRebuild
  module AgreementsCreationSteps
    extend ActiveSupport::Concern

    def create_agreements
      InternshipApplication.approved.each do |application|
        iag_builder = Builders::InternshipAgreementBuilder.new(user: Users::God.first)
        iag = iag_builder.new_from_application(application)
        iag.skip_notifications_when_system_creation = true
        info(iag.errors.full_messages.to_sentence) unless iag.valid?
        iag.save! if iag.valid?
      end
      InternshipAgreement.all.each do |iag|
        iag.complete!
        iag.start_by_school_manager!
        iag.finalize!
      end
      agreement = InternshipAgreement.troisieme_grades.first
      Signature.new(common_attributes(agreement, 'school_manager'))
               .save!
      agreement.sign!

      agreement = InternshipAgreement.troisieme_grades.second
      Signature.new(common_attributes(agreement, 'employer'))
               .save!
      agreement.sign!

      agreement = InternshipAgreement.seconde_grades.first
      Signature.new(common_attributes(agreement, 'school_manager'))
               .save!
      agreement.sign!

      agreement = InternshipAgreement.seconde_grades.second
      Signature.new(common_attributes(agreement, 'employer'))
               .save!
      agreement.sign!

      # --- pair signing
      agreement = InternshipAgreement.seconde_grades.third
      Signature.new(common_attributes(agreement, 'school_manager'))
               .save!
      agreement.sign!

      Signature.new(common_attributes(agreement, 'employer'))
               .save!
      agreement.sign!
      # agreement.signatures_finalize!
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
                       else
                         agreement.employer.id
                       end
      hash
    end
  end
end
