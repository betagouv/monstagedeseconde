require 'pretty_console'

# remove me after 2026/1/1
namespace :retrofit do
  desc 'updating empty strings from students_emails to nil'
  task parents_signing_updated_email: :environment do |task|
    PrettyConsole.announce_task(task) do
      date_mep = DateTime.new(2025,11,18,10,00,00)
      date_token_fix = DateTime.new(2025,11,24,18,28,00)
      sigs = Signature.where('created_at > ?', date_mep).where('created_at < ?', date_token_fix)
                      .where.not(internship_agreement_id: 48095) # exclude the one already fixed manually
      internship_agreements = sigs.map(&:internship_agreement).uniq
      PrettyConsole.say_in_yellow("Found #{internship_agreements.count} internship agreements to process")
      selected_internship_agreements = internship_agreements.select do |iag|
        iag.internship_application.approved_at < date_mep
      end
      PrettyConsole.say_in_cyan("Found #{selected_internship_agreements.count} internship agreements to update")

      next if selected_internship_agreements.empty?

      selected_internship_agreements= [selected_internship_agreements.first]

      selected_internship_agreements.each_with_index do |iag, index|
        PrettyConsole.say_in_blue("Processing #{index + 1}/#{selected_internship_agreements.count} - InternshipAgreement ID: #{iag.id}")
        legal_reps = iag.legal_representative_data.values
        legal_reps.each do |rep|
          if rep.present? && rep[:email].present? && rep[:email].strip.present?
            GodMailer.special_notify_student_legal_representatives_can_sign_email(
              internship_agreement: iag,
              representative: rep
            ).deliver_now
            PrettyConsole.say_in_green("Sent email to legal representative #{rep[:email]} for InternshipAgreement ID: #{iag .id}")
          else
            print 'x'
          end
        end
      end
    end
  end

  # remove me after 2026/1/1
  desc 'staging only updating empty strings from students_emails to nil'
  task staging_parents_signing_updated_email: :environment do |task|
    unless Rails.env.staging?
      puts 'This task can only be run in the staging environment'
      next
    end
    PrettyConsole.announce_task(task) do
      # date_mep = DateTime.new(2025,11,18,10,00,00)
      # date_token_fix = DateTime.new(2025,11,24,18,28,00)
      # sigs = Signature.where('created_at > ?', date_mep).where('created_at < ?', date_token_fix)
      # internship_agreements = sigs.map(&:internship_agreement).uniq
      # PrettyConsole.say_in_yellow("Found #{internship_agreements.count} internship agreements to process")
      # selected_internship_agreements = internship_agreements.select do |iag|
      #   iag.internship_application.approved_at < date_mep
      # end
      # PrettyConsole.say_in_cyan("Found #{selected_internship_agreements.count} internship agreements to update")

      selected_internship_agreements= [InternshipAgreement.find(56)]

      selected_internship_agreements.each_with_index do |iag, index|
        PrettyConsole.say_in_blue("Processing #{index + 1}/#{selected_internship_agreements.count} - InternshipAgreement ID: #{iag.id}")
        legal_reps = iag.legal_representative_data.values
        legal_reps.each do |rep|
          if rep.present? && rep[:email].present? && rep[:email].strip.present?
            GodMailer.special_notify_student_legal_representatives_can_sign_email(
              internship_agreement: iag,
              representative: rep
            ).deliver_now
            PrettyConsole.say_in_green("Sent email to legal representative #{rep[:email]} for InternshipAgreement ID: #{iag .id}")
          else
            print 'x'
          end
        end
      end
    end
  end
end