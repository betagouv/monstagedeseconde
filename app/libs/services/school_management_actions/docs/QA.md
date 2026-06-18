# QA — Digest d'actions chefs d'établissement (parcours via l'interface)

## Objectif

Dérouler manuellement, **via l'interface** (front élève + front employeur +
front chef d'établissement, et boîte mail), les scénarios qui déclenchent le
nouveau mail de digest "Résumé de vos actions en attente" envoyé au
représentant de l'établissement (chef d'établissement, CPE, etc.), pour
vérifier que chaque étape du cycle de vie d'une convention de stage produit
bien le bon comportement côté mail.

## Pré-requis

- Pouvoir déclencher manuellement les digests :
  - `bin/rails digest_mailers:send_low_urgency_emails`
  - `bin/rails digest_mailers:send_medium_urgency_emails`
  - `bin/rails digest_mailers:send_high_urgency_emails`
  - `bin/rails digest_mailers:send_critical_urgency_emails`

  Chaque tâche envoie le digest aux établissements ayant des actions de
  niveau égal ou supérieur au niveau déclenché (ex : "medium" inclut medium,
  high, critical).

## Scénario A — Convention complétée par l'employeur
1. **Élève** : postuler à l'offre, candidature acceptée par l'employeur.
2. **Employeur** : remplir/compléter la convention de stage jusqu'à l'état
   "complétée par l'employeur".
3. **Déclencher** le digest medium
   (`bundle exec rake digest_mailers:send_medium_urgency_emails`).
4. **Chef d'établissement** : ouvrir la boîte mail, vérifier la réception du
   mail "Résumé de vos actions en attente" contenant une section
   **"Conventions à compléter"** avec :
   - le nom de l'élève,
   - le nom de l'employeur,
   - le titre de l'offre,
   - la période (semaines),
   - un lien "Editer la convention" qui mène à la page d'édition de la
     convention.

## Scénario B — Convention en attente de la signature de l'établissement
1. Reprendre la convention du scénario A, la compléter entièrement côté
   établissement/employeur jusqu'à activer les signatures
2. **Déclencher** le digest medium
   (`bundle exec rake digest_mailers:send_medium_urgency_emails`).
3. même s'il est le dernier à avoir édité la convention et qu'il accède ainsi aux signatures, 
   un mail action item est ajouté pour le chef d'établissement au cas où il oublierait de
   signer dans la foulée.
   (`signatures_enabled`)

   ⚠️ Cet item est créé par le job `GodMailer.notify_signatures_can_start_email`
   (envoyé via `deliver_later`). Avant de déclencher le digest, s'assurer que
   ce job a bien été traité (worker Sidekiq actif / `bin/rails jobs:work`),
   sinon l'item n'existe pas encore et le digest n'aura rien à envoyer.
4. Vérifier la réception immédiate (hors digest, envoi direct via
   `GodMailer`) du mail "Imprimez et signez la convention de stage" — ce mail
   ne doit **pas** être envoyé au représentant de l'établissement car il est sera informé
   par digest s'il oublie de signer
5. **Déclencher** le digest medium.
6. **Chef d'établissement** : vérifier la réception du mail de digest avec
   une section **"Conventions prêtes à être signées"** contenant :
   - le nom de l'élève,
   - le nom de l'employeur,
   - le titre du stage,
   - un lien "Signer la convention de stage" menant à la page de la
     convention.

## Scénario C — Convention prête à être signée (signature démarrée par une autre partie)
1. Reprendre une convention dont les signatures sont activées et où il manque
   encore la signature de l'établissement.
2. Faire signer une première partie (élève ou employeur).
3. Vérifier la réception immédiate (hors digest) du mail "Une convention de
   stage attend votre signature" — ce mail ne doit **pas** être envoyé au
   représentant de l'établissement s'il lui reste à signer (il est notifié
   par le digest à la place).
4. **Déclencher** le digest medium.
5. **Chef d'établissement** : vérifier la réception du mail de digest avec
   une section **"Conventions prêtes à être signées"** contenant :
   - le nom de l'élève,
   - le titre de l'offre et le nom de l'employeur,
   - un lien "Signer la convention de stage" menant à la page de la
     convention.

## Scénario D — Convention signée par toutes les parties
1. Reprendre une convention en cours de signature.
2. Faire signer toutes les parties manquantes, **y compris** la signature de
   l'établissement, jusqu'à ce que la convention passe à l'état "signée par
   tous".
3. Vérifier la réception immédiate (hors digest) du mail "Une convention de
   stage est signée par tous" — ce mail ne doit **pas** être envoyé au
   représentant de l'établissement (il est notifié par le digest à la place).
4. **Déclencher** le digest medium.
5. **Chef d'établissement** : vérifier la réception du mail de digest avec
   une section **"Conventions signées par toutes les parties"** contenant :
   - le nom de l'élève,
   - le titre de l'offre,
   - un lien "Voir la convention signée" menant à la convention.

## Scénario E — Convention déjà signée par l'établissement (pas de doublon)
1. Reprendre le scénario C, mais où la **dernière** signature manquante est
   celle de l'établissement (l'établissement signe en dernier).
2. **Chef d'établissement** : signer la convention (dernière signature).
3. **Déclencher** le digest medium.
4. Vérifier qu'**aucun** mail "Conventions prêtes à être signées" n'est
   reçu pour cette convention (l'établissement vient de signer, il n'a pas
   besoin d'être notifié pour signer une convention qu'il vient de signer).
   Aucun email n'est envoyé au chef d'établissement.

## Scénario F — Établissement sans représentant identifié
1. Préparer une convention de stage pour un élève rattaché à un
   établissement de test **sans** compte pour la totalité du lycée associé.
2. Faire avancer la convention jusqu'à l'étape "complétée par l'employeur"
   (déclenche normalement `internship_agreement_completed_by_employer`).
3. **Déclencher** le digest medium.
4. Vérifier qu'**aucun** mail de digest "chef d'établissement" n'est envoyé
   pour cet établissement (et qu'un warning est présent dans les logs
   serveur : "No recipient found for school management digest email for
   agreement ...").

## Scénario G — Regroupement multi-actions dans un seul mail

1. Préparer, pour le même établissement et le même représentant, deux
   conventions à des étapes différentes : une "complétée par l'employeur"
   (medium) et une "signée par toutes les parties" (medium).
2. **Déclencher** le digest medium une seule fois.
3. **Chef d'établissement** : vérifier que le mail reçu regroupe bien les
   deux sections ("Conventions à compléter" et "Conventions signées par
   toutes les parties") dans un seul email.

## Check-list de fin de session

- [ ] Tous les mails de digest "chef d'établissement" attendus ont bien été
      reçus, avec le bon contenu (nom de l'élève, employeur, offre, période)
      et les bons liens vers les conventions.
- [ ] Aucun mail de digest n'est envoyé pour un établissement 
      représentant identifié (warning loggé à la place).
- [ ] Les mails directs (`GodMailer`) liés à la signature
      (`notify_others_signatures_started_email`,
      `notify_others_signatures_finished_email`,
      `notify_signatures_can_start_email`) n'incluent **plus** le
      représentant de l'établissement quand celui-ci a une action
      correspondante en attente dans le digest, afin d'éviter les doublons.
- [ ] Les liens contenus dans les mails de digest amènent bien sur les bonnes
      pages de la convention de stage.
