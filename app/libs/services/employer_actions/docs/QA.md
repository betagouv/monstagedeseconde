# QA — Digest d'actions employeur (parcours via l'interface)

## Objectif

Dérouler manuellement, **via l'interface** (front élève + front employeur, et
boîte mail), les scénarios qui déclenchent les mails de digest employeur, pour
vérifier que chaque action métier produit bien le bon comportement côté mail.

Pour le détail technique des `MailActionItem` attendus (champs, urgence,
résolution), se référer à [recette_employer_digest.md](recette_employer_digest.md).
Ce document-ci ne décrit que les **actions à réaliser dans l'UI**.

## Pré-requis

- Un compte employeur de test connecté, avec une offre publiée et des semaines
  disponibles.
- Un ou plusieurs comptes élèves de test connectés (dans une autre session/navigateur).
- Pouvoir déclencher manuellement les digests (rake tasks, cf. doc technique).

## Scénario A — Nouvelle candidature

1. **Élève** : se connecter, rechercher l'offre de test, postuler.
2. **Déclencher** le digest medium.
3. **Employeur** : ouvrir la boîte mail, vérifier la réception d'un mail de
   digest mentionnant la nouvelle candidature.
4. Cliquer sur le lien du mail, vérifier l'arrivée sur la page de la candidature.

## Scénario B — Candidature lue puis annulée par l'élève

1. **Élève** : postuler à l'offre.
2. **Employeur** : se connecter, ouvrir/consulter la candidature dans son tableau
   de bord (pour la marquer comme lue).
3. **Élève** : annuler la candidature depuis son espace.
4. **Déclencher** le digest medium.
5. **Employeur** : vérifier la réception du mail "candidature annulée" dans la
   boîte mail.
6. Vérifier que le mail "nouvelle candidature" envoyé en étape 1 est toujours
   présent dans l'historique (pas de disparition liée à l'annulation).
7. **Déclencher** le digest medium.
8. Aucun email n'est envoyé, Info Emails est vide

## Scénario C — Candidature jamais lue puis annulée par l'élève

1. **Élève** : postuler à l'offre.
(2. **Employeur** : ne pas ouvrir la candidature.)
3. **Élève** : annuler la candidature.
4. **Déclencher** le digest medium.
5. **Employeur** : vérifier qu'**aucun** mail d'annulation ou de candidature n'est reçu 

## Scénario D — Candidature restaurée après annulation

### D1. Lue → annulée → restaurée (mail attendu)
1. **Élève** : postuler.
2. **Employeur** : ouvrir la candidature.
3. **Élève** : annuler puis restaurer la candidature depuis son espace.
4. **Déclencher** le digest medium.
5. **Employeur** : vérifier la réception du mail de restauration. Il doit y avoir un message de candidature, mais rien sur l'annulation/restauration

### D2. Jamais lue → annulée → restaurée (pas de mail)
1. **Élève** : postuler.
(2. **Employeur** : ne jamais ouvrir la candidature.)
3. **Élève** : annuler puis restaurer la candidature.
4. **Déclencher** le digest medium.
5. **Employeur** : vérifier qu'**aucun** mail de restauration n'est reçu, mais que la candidature est signalée dans le digest

### D3. Lue → annulée → restaurée → ré-annulée avant le digest
1. Reprendre les étapes du D1 jusqu'à la restauration.
2. **Élève** : annuler à nouveau la candidature, avant de déclencher le digest.
3. **Déclencher** le digest medium.
4. **Employeur** : vérifier qu'**aucun** mail de restauration n'est reçu, mais qu'il y a signalement de l'annulation, mais une seule fois.

## Scénario E — Confirmation d'annulation par l'élève (urgence haute)
1. **Élève** : postuler, puis engager le flux d'annulation jusqu'à
   confirmation explicite ("confirmer l'annulation").
2. **Déclencher** le digest high (ou critical selon la temporisation).
3. **Employeur** : vérifier la réception du mail correspondant, marqué comme
   urgent dans son contenu/objet.

## Scénario F — Cycle de vie d'une convention de stage
1. **Employeur/Élève** : générer une convention de stage à compléter pour la
   candidature acceptée.
2. **Déclencher** le digest medium, vérifier le mail "convention à compléter".
3. Compléter la convention, la faire signer par une première partie (élève ou
   responsable légal).
4. **Déclencher** le digest medium, vérifier le mail "convention à signer" /
   "signée par une autre partie" reçu par l'employeur.
5. **Employeur** : signer la convention à son tour (dernière signature
   manquante).
6. **Déclencher** le digest medium : aucun email ne doit être envoyé.
   - L'item `agreement_to_sign` est résolu (l'employeur a signé).
   - L'item `agreement_signed_by_all` créé par la dernière signature est également
     résolu (l'employeur sait qu'il vient de signer : pas besoin de le notifier).

### F2b — Élève signe en premier (cas particulier)

1. **Élève** : signer la convention avant l'employeur.
2. **Déclencher** le digest medium.
3. **Employeur** : vérifier que le mail contient bien la section "Conventions de
   stage à signer" avec le nom de l'élève et un lien "Voir la convention".
4. **Employeur** : vérifier que le mail contient aussi la section "Conventions
   signées par un autre élève" avec le nom de l'élève et le titre de l'offre.

## Scénario G — Absence de notification

1. **Employeur** : se connecter avec un compte de test sans aucune action en
   attente (aucune candidature/convention/offre récente).
2. **Déclencher** les quatre digests (low, medium, high, critical).
3. Vérifier qu'**aucun** mail n'est reçu pour ce compte.

## Scénario H — Regroupement multi-niveaux

1. Préparer simultanément, pour le même employeur :
   - une offre dépubliée (low),
   - une nouvelle candidature (medium),
   - une confirmation d'annulation (high).
2. **Déclencher** le digest high.
3. **Employeur** : vérifier que le mail reçu regroupe bien les actions de niveau
   égal ou supérieur (low + medium + high), sans doublon avec un digest de
   niveau inférieur déjà envoyé précédemment.

## Check-list de fin de session

- [ ] Tous les mails attendus ont bien été reçus, avec le bon contenu et les
      bons liens de redirection vers l'interface.
- [ ] Aucun mail inattendu n'a été reçu (cas de résolution silencieuse).
- [ ] Les liens contenus dans les mails amènent bien sur les bonnes pages de
      l'application (candidature, convention, offre).
- [ ] La mise en forme des mails (urgence, regroupement d'actions) est correcte
      visuellement.
