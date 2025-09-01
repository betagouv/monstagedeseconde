module ReviewRebuild
  module AgreementsCreationSteps
    extend ActiveSupport::Concern

    def create_agreements
      InternshipApplication.approved.each do |application|
        iag_builder = Builders::InternshipAgreementBuilder.new(user: Users::God.first)
        iag = iag_builder.new_from_application(application)
        info(iag.errors.full_messages.to_sentence) unless iag.valid?
        iag.save! if iag.valid?
      end
      InternshipAgreement.all.each do |iag|
        iag.complete!
        iag.start_by_school_manager!
        iag.finalize!
      end
      internship_agreements.troisieme_grades.first(2).each do |agreement|
        Signature.new(signatory_role: 'school_manager',
                      user: agreement.school_manager,
                      internship_agreement: agreement).save!
      end

      internship_agreements.seconde_grades.first(2).each do |agreement|
        Signature.new(signatory_role: 'school_manager',
                      user: agreement.school_manager,
                      internship_agreement: agreement).save!
      end
    end
  end
end
