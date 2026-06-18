# frozen_string_literal: true

module Presenters
  class DigestMailer
    ACTION_LABELS = {
      "new_internship_application"                   => "Nouvelle candidature",
      "internship_application_rejected"              => "Candidature rejetée",
      "internship_application_validated_by_employer" => "Candidature validée par l'employeur",
      "internship_application_expired"               => "Candidature expirée",
      "canceled_internship_application_by_student"   => "Candidature annulée par l'élève",
      "restored_internship_application"              => "Candidature restaurée",
      "cancel_by_student_confirmation"               => "Confirmation d'annulation par l'élève",
      "candidate_chose_another_internship"           => "Élève ayant choisi un autre stage",
      "candidate_restored_by_student"                => "Candidature réactivée par l'élève",
      "canceled_internship_application"              => "Candidature annulée (employeur)",
      "internship_application_transfered"            => "Candidature transférée",
      "internship_agreement_completed_by_employer"   => "Convention complétée par l'employeur",
      "new_agreement_to_fill_in"                     => "Nouvelle convention à compléter",
      "agreement_signed_by_another"                  => "Convention signée par un autre élève",
      "agreement_to_sign"                            => "Convention à signer",
      "signatures_enabled"                           => "Signatures électroniques ouvertes",
      "agreement_signed_by_all"                      => "Convention signée par toutes les parties"
    }.freeze

    URGENCY_OPTIONS = [
      [ "Faible",   "low" ],
      [ "Moyen",    "medium" ],
      [ "Élevé",    "high" ],
      [ "Critique", "critical" ]
    ].freeze

    def sections
      {
        "Candidatures"    => MailActionConfig::PENDING_APPLICATION_CONFIGS.keys,
        "Conventions"     => MailActionConfig::PENDING_AGREEMENT_CONFIGS.keys
      }
    end

    def label_for(action_name)
      ACTION_LABELS[action_name] || action_namestash
    end
  end
end
