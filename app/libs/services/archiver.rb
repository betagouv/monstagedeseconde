module Services
  # Services::StudentArchiver.new(begins_at: Date.new(2019, 9, 1), ends_at: Date.new(2020, 8, 31))
  class Archiver
    def self.archive_students
      Users::Student.kept
                    .in_batches(of: 100)
                    .each_record(&:archive)
    end

    def self.delete_invitations
      Invitation.in_batches(of: 100)
                .each_record(&:destroy)
    end

    def self.archive_internship_agreements
      InternshipAgreement.kept
                         .in_batches(of: 100)
                         .each_record(&:archive)
    end

    def self.archive_identities
      Identity.in_batches(of: 100)
              .each_record(&:archive)
    end

    def self.archive_internship_applications
      InternshipApplication.in_batches(of: 100)
                           .each_record do |internship_application|
        internship_application.anonymize
        internship_application.save
      end
    end

    def self.archive_internship_offers
      InternshipOffer.in_batches(of: 100)
                     .each_record(&:archive)
    end

    def self.archive_class_rooms
      ClassRoom.in_batches(of: 100)
               .each_record(&:archive)
    end
  end
end
