# frozen_string_literal: true
require 'fileutils'
require 'pretty_console'

namespace :employers do
  desc 'Reminder for employers with pending internship applications'
  task :pending_internship_applications_reminder, [] => [:environment] do |args|
    PrettyConsole.say_in_green 'Starting employers:pending_internship_applications_reminder'
    employers = Users::Employer.kept.select do |employer|
      # september_flower transfer might comme back at some point6
      # employer.internship_applications.pending_for_employers.present? || employer.internship_applications.examined.present?
      employer.internship_applications.pending_for_employers.present?
    end

    PrettyConsole.say_in_red "Found #{employers.count} employers with pending internship applications"

    employers.each do |employer|
      Triggered::EmployerInternshipApplicationsReminderJob.perform_later(employer)
    end
    PrettyConsole.say_in_green 'Finished employers:pending_internship_applications_reminder'

    GodMailer.employer_global_applications_reminder(employers.count).deliver_now
  end
end
