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
      InternshipAgreement.troisieme_grades.first(2).each do |agreement|
        Signature.new(signatory_role: 'school_manager',
                      user_id: agreement.school_manager.id,
                      signature_date: Time.current,
                      signatory_ip: FFaker::Internet.ip_v4_address,
                      signature_phone_number: '+33123456789',
                      internship_agreement: agreement).save!
      end

      InternshipAgreement.seconde_grades.first(2).each do |agreement|
        Signature.new(signatory_role: 'school_manager',
                      user_id: agreement.school_manager.id,
                      signature_date: Time.current,
                      signatory_ip: FFaker::Internet.ip_v4_address,
                      signature_phone_number: '+33123456789',
                      internship_agreement: agreement).save!
      end
    end
  end
end
