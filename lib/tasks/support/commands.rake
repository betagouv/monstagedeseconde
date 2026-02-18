require 'pretty_console'
namespace :support do
  desc "relancer la signature des conventions de stage en attente de signature du chef d'établissement"
  task :agreement_signature_email,  [:uuid, :role] => :environment do |t, args|
    #usage : bundle exec rake support:agreement_signature_email[87089d99-9a30-4044-b20f-72686ddb51ec,student_legal_representative]
    #role doit être pris dans [school_manager, employer, cpe, admin_officer, other, teacher, student, student_legal_representative]
    uuid = args[:uuid]
    role = args[:role]
    if uuid.present? && role.present?
      if ['school_manager', 'employer', 'cpe', 'admin_officer', 'other', 'teacher', 'student', 'student_legal_representative'].include?(role)
        internship_agreement = InternshipAgreement.find_by(uuid: uuid)
        if internship_agreement.nil?
          PrettyConsole.say_in_red "Convention avec uuid #{uuid} non trouvée, email de relance non envoyé"
        else
          last_signature = Signature.where(internship_agreement_id: internship_agreement.id).last
          signature_recipients = case role
                                when 'student'
                                  [internship_agreement.student.email]
                                when 'school_manager', 'cpe', 'admin_officer', 'other', 'teacher'
                                  [internship_agreement.school_management_representative.email]
                                when 'student_legal_representative'
                                  [internship_agreement.student_legal_representative_email]
                                when 'employer'
                                  [internship_agreement.employer.email]
                                else
                                  nil
                                end
          if internship_agreement.present? && signature_recipients.present?
            GodMailer.notify_others_signatures_started_email(
            internship_agreement: internship_agreement,
            missing_signatures_recipients: signature_recipients,
            last_signature: last_signature).deliver_now
            PrettyConsole.say_in_yellow "Email de relance envoyé à #{role} pour la convention #{internship_agreement.id}"
          else
            PrettyConsole.say_in_red "Convention avec uuid #{uuid} non trouvée ou bien le rôle a déjà signé, email de relance non envoyé"
          end
        end
      else
         PrettyConsole.say_in_cyan "Rôle #{role} non valide, email de relance non envoyé, les rôles valides sont : school_manager, employer, cpe, admin_officer, other, teacher, student, student_legal_representative"
      end
    else
      PrettyConsole.say_in_cyan "UUID ou rôle manquant, email de relance non envoyé"
    end
  end
end
