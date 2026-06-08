require "pretty_console"
# usage : rake retrofit:internship_agreements_dedoubling
#
# Outil de fallback manuel : la migration AddUniqueIndexOnInternshipAgreementsApplication
# fait déjà le nettoyage automatique des doublons sûrs (sans signature). Cette tâche est
# seulement utile si la migration a refusé de continuer parce qu'il restait des applications
# avec plusieurs conventions signées (cas anormal qui nécessite une revue avant de discarder).

include PrettyConsole
namespace :retrofit do
  desc "Discard les conventions de stage dupliquées (garde celle avec signatures, sinon la plus récente)"
  task internship_agreements_dedoubling: :environment do
    duplicates = InternshipAgreement
                   .kept
                   .group(:internship_application_id)
                   .having("COUNT(*) > 1")
                   .pluck(:internship_application_id)

    PrettyConsole.say_in_yellow "Found #{duplicates.size} application(s) with duplicated agreements"

    discarded_count = 0
    duplicates.each do |application_id|
      agreements = InternshipAgreement
                     .kept
                     .where(internship_application_id: application_id)
                     .order(:created_at)
                     .to_a

      keeper = agreements.find { |a| a.signatures.any? } || agreements.last
      to_discard = agreements - [ keeper ]

      to_discard.each do |a|
        next if a.signatures.any?

        a.update_columns(discarded_at: Time.current)
        discarded_count += 1
        PrettyConsole.say_in_green "  app##{application_id} : discard agr##{a.id} (keep ##{keeper.id})"
      end
    end

    PrettyConsole.say_in_green "Done. #{discarded_count} agreement(s) discarded."
  end
end
