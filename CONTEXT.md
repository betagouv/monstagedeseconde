# Glossaire domaine — Mon Stage de Seconde - en cours de remplissage

## InternshipApplication
Candidature d'un élève à une offre de stage. Porte la machine à états AASM (submitted → approved, rejected, etc.).

## InternshipOffer
Offre de stage publiée par un employeur. Deux sous-types STI : `WeeklyFramed` (offres hebdomadaires) et `Multi`.

## Stats (`InternshipOfferStats`)
Projection dénormalisée des compteurs d'une offre : nombre de candidatures par état, par genre, places restantes. Mise à jour après chaque commit sur une candidature via `recompute_offer_stats`. Source de vérité pour les scopes SQL et l'affichage.

## remaining_seats_count
Nombre de places disponibles sur une offre. Deux usages intentionnels et distincts :
- **Lecture** : colonne en base dans `InternshipOfferStats`, utilisée pour les scopes SQL et l'affichage.
- **Garde de validation** : calcul live (`max_candidates - approved.count`) dans les sous-classes STI, pour se prémunir d'un race condition lors de la soumission d'une candidature.

## recompute_offer_stats
Opération qui recalcule l'intégralité des stats d'une offre (compteurs + favoris) depuis la base. Projection complète, pas un delta. Déclenchée via `after_commit` sur `InternshipApplication`.
