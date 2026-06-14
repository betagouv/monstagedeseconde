# Protocole de test manuel — digest d'actions employeur (employer_actions)

## Objectif

Vérifier de bout en bout le fonctionnement des mails de "digest" envoyés aux
employeurs pour les notifier des actions en attente sur leurs candidatures, leurs
conventions et leurs offres de stage.

Le digest regroupe des `MailActionItem` par niveau d'urgence (`low`, `medium`,
`high`, `critical`) et envoie un mail récapitulatif par niveau, via
`Services::EmployerActions::EmployerDigestMailer`.

## Pré-requis

- Un compte employeur de test avec une offre publiée et des semaines disponibles.
- Un ou plusieurs comptes élèves de test.
- Dans l'environnemnet de test, déclencher manuellement les tâches rake :
  ```
  bin/rails digest_mailers:send_low_urgency_emails
  bin/rails digest_mailers:send_medium_urgency_emails
  bin/rails digest_mailers:send_high_urgency_emails
  bin/rails digest_mailers:send_critical_urgency_emails
  ```
- Avoir accès à la boîte mail de l'employeur (ou Letter Opener / Mailcatcher en local).
- Pouvoir inspecter la table `mail_action_items` (console Rails ou DB) pour vérifier
  les champs `action_name`, `action_type`, `urgency_level`, `resolved_at`,
  `deliveries_count`, `last_notified_at`, `stale_at`.

## Principe général à vérifier pour chaque scénario

Pour chaque action testée :
1. **Déclenchement** : l'action métier (candidature, convention, offre) crée bien un
   `MailActionItem` avec le bon `action_name`, `action_type` et `urgency_level`
   (voir tableau de référence ci-dessous), avec `resolved_at: nil`.
2. **Résolution** : si l'état change de façon à rendre la notification obsolète
   (ex: candidature à nouveau soumise, convention signée, etc.), l'item doit être
   marqué résolu (`resolved_at` renseigné) et **ne pas** générer de mail — sans
   pour autant supprimer ou résoudre par erreur d'autres items en attente liés au
   même enregistrement (cf. scénario de non-régression plus bas).
3. **Envoi** : si l'item reste en attente (`pending`, non périmé `stale_at`), le mail
   de digest correspondant au niveau d'urgence doit être envoyé à l'employeur, et
   l'item doit voir son `deliveries_count` incrémenté et `last_notified_at` renseigné.
4. **Non-renvoi après résolution** : un item résolu ou ayant atteint son
   `max_deliveries_count` ne doit plus générer d'envoi, et finit par être supprimé
   (purge par le `Resolver`).

## Tableau de référence des actions

| action_name | action_type | urgency_level | déclencheur métier |
|---|---|---|---|
| `new_internship_application` | pending_internship_application | medium | élève soumet une candidature |
| `canceled_internship_application_by_student` | pending_internship_application | medium | élève annule une candidature (mail envoyé seulement si l'employeur l'avait déjà lue) |
| `restored_internship_application` | pending_internship_application | medium | candidature restaurée après annulation |
| `cancel_by_student_confirmation` | pending_internship_application | high | élève confirme l'annulation |
| `candidate_chose_another_internship` | pending_internship_application | high | élève choisit un autre stage |
| `candidate_restored_by_student` | pending_internship_application | medium | élève restaure sa candidature |
| `canceled_internship_application` | pending_internship_application | low | candidature annulée (côté employeur/système) |
| `internship_application_transfered` | pending_internship_application | medium | candidature transférée |
| `new_agreement_to_fill_in` | pending_internship_agreement | medium | nouvelle convention à compléter |
| `agreement_signed_by_another` | pending_internship_agreement | low | convention signée par une autre partie |
| `agreement_to_sign` | pending_internship_agreement | medium | convention à signer par l'employeur |
| `signatures_enabled` | pending_internship_agreement | medium | signatures activées sur la convention |
| `agreement_signed_by_all` | pending_internship_agreement | medium | convention signée par toutes les parties |
| `internship_offer_unpublished` | pending_internship_offer | low | offre dépubliée |
| `internship_offer_removed` | pending_internship_offer | high | offre supprimée |

## Scénarios à dérouler

### 1. Nouvelle candidature → mail "nouvelle candidature"
- L'élève postule. Vérifier la création du `MailActionItem`
  `new_internship_application` (medium), puis l'envoi du digest medium et la
  réception du mail par l'employeur.

### 2. Candidature lue puis annulée par l'élève → mail d'annulation
- L'employeur ouvre/lit la candidature (`read_by_employer`), puis l'élève l'annule.
- Vérifier la création de `canceled_internship_application_by_student` (medium),
  son maintien en attente (`resolved_at: nil`), et la réception du mail au prochain
  digest medium.
- **Non-régression** : vérifier que le mail "nouvelle candidature" associé à cette
  même candidature (résolu entre-temps car la candidature n'est plus `submitted`)
  ne fait pas disparaître/résoudre par erreur le mail d'annulation — les deux items
  doivent être traités indépendamment.

### 3. Candidature jamais lue puis annulée par l'élève → pas de mail d'annulation
- L'élève postule, l'employeur **ne consulte pas** la candidature, l'élève annule.
- Vérifier que `canceled_internship_application_by_student` est créé puis marqué
  `resolved_at` (résolu) avant tout envoi, et qu'**aucun** mail d'annulation n'est
  reçu par l'employeur.

### 4. Candidature restaurée après annulation

La résolution de `restored_internship_application` dépend de deux conditions
(voir `Resolver#resolve`) : l'item est marqué résolu (sans envoi de mail) si la
candidature **n'est plus à l'état `restored`** (`not_restored`) **ou** si elle
**n'a jamais été lue par l'employeur** (`never_seen_by_employer`). Il faut donc
dérouler séparément les sous-cas où chaque condition bascule.

#### 4a. Candidature lue, annulée puis restaurée → mail de restauration
- L'employeur ouvre/lit la candidature (`read_by_employer`), l'élève l'annule,
  puis la candidature est restaurée (`aasm_state: restored`).
- Vérifier la création de `restored_internship_application` (medium), son
  maintien en attente (`resolved_at: nil` car `not_restored` et
  `never_seen_by_employer` sont tous deux faux), et la réception du mail au
  prochain digest medium.
- **Non-régression** : comme au scénario 2, vérifier que les items liés
  (`canceled_internship_application_by_student`, etc.) déjà résolus sur cette
  même candidature ne sont pas affectés et que `restored_internship_application`
  est traité indépendamment.

#### 4b. Candidature jamais lue, annulée puis restaurée → pas de mail de restauration
- L'élève postule, l'employeur **ne consulte jamais** la candidature, l'élève
  l'annule, puis elle est restaurée.
- Vérifier que `restored_internship_application` est créé puis marqué
  `resolved_at` (résolu via `never_seen_by_employer`) avant tout envoi, et
  qu'**aucun** mail de restauration n'est reçu par l'employeur.

#### 4c. Candidature restaurée puis ré-annulée avant l'envoi du digest → pas de mail
- Restaurer une candidature lue par l'employeur (cf. 4a), puis l'annuler à
  nouveau avant le passage du digest, de sorte que `aasm_state` ne soit plus
  `restored`.
- Vérifier que `restored_internship_application` est marqué résolu via
  `not_restored` (même si la candidature a bien été lue), et qu'aucun mail de
  restauration n'est envoyé.

### 5. Confirmation d'annulation par l'élève
- Dérouler le flux de confirmation d'annulation (`cancel_by_student_confirmation`,
  urgency `high`). Vérifier création, envoi au digest high/critical, et résolution
  si la candidature change d'état avant l'envoi.

### 6. Convention : à compléter, à signer, signée par tous
- Créer une convention (`new_agreement_to_fill_in`), la faire signer partiellement
  (`agreement_to_sign`, `agreement_signed_by_another`), puis entièrement
  (`agreement_signed_by_all`). Vérifier la création et la résolution successive des
  `MailActionItem` correspondants, et la réception des mails de digest associés
  (urgency medium).

### 7. Offre dépubliée / supprimée
- Dépublier une offre : vérifier `internship_offer_unpublished` (low) et le mail
  reçu au digest low.
- Supprimer une offre : vérifier `internship_offer_removed` (high) et le mail reçu
  au digest high/critical.

### 8. Péremption (`stale_at`) et plafond d'envoi (`max_deliveries_count`)
- Provoquer une notification dont le `stale_at` est dans le passé (ou attendre qu'il
  le devienne) : vérifier qu'elle est purgée par le `Resolver` sans envoi de mail.
- Provoquer plusieurs cycles de digest sur une même notification non résolue :
  vérifier qu'au-delà de `max_deliveries_count` envois, l'item est purgé et plus
  aucun mail n'est envoyé pour cette action.

### 9. Regroupement multi-niveaux dans un même digest
- Avoir simultanément des `MailActionItem` en attente à plusieurs niveaux d'urgence
  pour un même employeur (ex: low + medium + high). Déclencher le digest d'un niveau
  donné et vérifier qu'il regroupe bien les niveaux égaux ou supérieurs (cf.
  `urgency_levels_sum_up`), sans dupliquer les actions déjà couvertes par un digest
  de niveau inférieur déjà envoyé.

## Points d'attention transverses

- Un employeur sans actions en attente ne doit recevoir aucun mail de digest (cf.
  log "No pending and not overdue actions to notify").
- Les actions résolues doivent disparaître de la base après le passage du
  `Resolver` (purge), sans avoir généré de mail.
- Vérifier qu'aucune action n'est "perdue" (résolue par erreur) ni "dupliquée"
  (envoyée plusieurs fois au-delà de son plafond) lors de l'enchaînement de
  plusieurs scénarios sur la même candidature/convention/offre.
