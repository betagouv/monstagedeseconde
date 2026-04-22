require 'pretty_console'
namespace :support do
  desc "relancer la signature des conventions de stage en attente de signature du chef d'établissement"
  task :agreement_signature_email,  [ :uuid, :role ] => :environment do |t, args|
    # usage : bundle exec "rake support:agreement_signature_email[87089d99-9a30-4044-b20f-72686ddb51ec,student_legal_representative]"
    # role doit être pris dans [school_manager, employer, cpe, admin_officer, other, teacher, student, student_legal_representative]
    uuid = args[:uuid]
    role = args[:role]
    if uuid.present? && role.present?
      if %w[school_manager employer cpe admin_officer other teacher student student_legal_representative].include?(role)
        internship_agreement = InternshipAgreement.find_by(uuid: uuid)
        if internship_agreement.nil?
          PrettyConsole.say_in_red "Convention avec uuid #{uuid} non trouvée, email de relance non envoyé"
        else
          last_signature = internship_agreement.signatures.last
          email = case role
          when 'student'
                    internship_agreement.student&.email
          when 'school_manager', 'cpe', 'admin_officer', 'other', 'teacher'
                    internship_agreement.school_management_representative&.email
          when 'student_legal_representative'
                    internship_agreement.student_legal_representative_email
          when 'employer'
                    internship_agreement.employer.email
          else
                    nil
          end
          signature_recipients = [ email ].compact.presence
          if signature_recipients.present?
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
      PrettyConsole.say_in_cyan 'UUID ou rôle manquant, email de relance non envoyé'
    end
  end

  desc 'update internship_agreements following fields school_representative_email and school_representative_full_name'
  task :update_internship_agreements_school_representative,  [ :email, :full_name, :school_uai_code, :from_date ] => :environment do |t, args|
    # usage : bundle exec "rake support:update_internship_agreements_school_representative [test@free.fr,Marine_Marchande,0371417P,12/2/2026]"
    email = args[:email].strip
    full_name = args[:full_name].strip.gsub(/_/, ' ')
    school_uai_code = args[:school_uai_code].strip
    from_date = args[:from_date].strip
    date = Date.strptime(from_date, '%d/%m/%Y') rescue nil
    puts '-'*60
    puts "email: #{email}, full_name: #{full_name}, school_uai_code: #{school_uai_code}, from_date: #{date}"
    puts '-'*60
    if date.nil?
      PrettyConsole.say_in_cyan "Date de début #{from_date} invalide, format attendu : dd/mm/yyyy, aucune convention mise à jour"
      next
    end
    if email.split('@').size != 2 || email.split('@').last.split('.').size < 2
      PrettyConsole.say_in_cyan "Email #{email} invalide, format attendu : xxx@xxx.xxx, aucune convention mise à jour"
      next
    end

    if email.present? && full_name.present? && school_uai_code.present? && date.present?
      school = School.find_by(code_uai: school_uai_code)
      if school.nil?
        PrettyConsole.say_in_red "Aucune école trouvée avec le code UAI #{school_uai_code}, aucune convention mise à jour"
      else
        updated_count = InternshipAgreement.joins(internship_application: :student)
                                           .where(student: { school_id: school.id })
                                           .where('internship_agreements.created_at >= ?', date)
                                           .update_all(school_representative_email: email, school_representative_full_name: full_name)
        PrettyConsole.say_in_green "#{updated_count} conventions mises à jour pour l'école #{school.name} (UAI #{school_uai_code}) avec le représentant scolaire #{full_name} (#{email})"
      end
    else
      PrettyConsole.say_in_cyan 'Email, nom complet, code UAI de l\'école ou date de début manquants, aucune convention mise à jour'
    end
  end

  desc 'update school_representative_email and school_representative_full_name internship_agreements fields with data from a user'
  task :update_internship_agreements_school_representative_with_user_data,  [ :user_id, :school_uai_code, :from_date ] => :environment do |t, args|
    # usage : bundle exec "rake support:update_internship_agreements_school_representative_with_user_data [user_id,0371417P,12/2/2026]"
    user = User.find_by(id: args[:user_id])
    if user.nil?
      PrettyConsole.say_in_red "Aucun utilisateur trouvé avec l'ID #{args[:user_id]}, aucune convention mise à jour"
      next
    end
    email = user.email
    full_name = user.presenter.full_name
    school_uai_code = args[:school_uai_code].strip
    from_date = args[:from_date].strip
    date = Date.strptime(from_date, '%d/%m/%Y') rescue nil
    puts '-'*60
    puts "email: #{email}, full_name: #{full_name}, school_uai_code: #{school_uai_code}, from_date: #{date}"
    puts '-'*60
    if date.nil?
      PrettyConsole.say_in_cyan "Date de début #{from_date} invalide, format attendu : dd/mm/yyyy, aucune convention mise à jour"
      next
    end
    if email.split('@').size != 2 || email.split('@').last.split('.').size < 2
      PrettyConsole.say_in_cyan "Email #{email} invalide, format attendu : xxx@xxx.xxx, aucune convention mise à jour"
      next
    end

    if email.present? && full_name.present? && school_uai_code.present? && date.present?
      school = School.find_by(code_uai: school_uai_code)
      if school.nil?
        PrettyConsole.say_in_red "Aucune école trouvée avec le code UAI #{school_uai_code}, aucune convention mise à jour"
      else
        updated_count = InternshipAgreement.joins(internship_application: :student)
                                           .where(student: { school_id: school.id })
                                           .where('internship_agreements.created_at >= ?', date)
                                           .update_all(school_representative_email: email, school_representative_full_name: full_name)
        PrettyConsole.say_in_green "#{updated_count} conventions mises à jour pour l'école #{school.name} (UAI #{school_uai_code}) avec le représentant scolaire #{full_name} (#{email})"
      end
    else
      PrettyConsole.say_in_cyan 'Email, nom complet, code UAI de l\'école ou date de début manquants, aucune convention mise à jour'
    end
  end
end
