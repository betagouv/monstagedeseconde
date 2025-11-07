# Système de modération des signalements d'offres inappropriées

## Vue d'ensemble

Ce système permet aux administrateurs (Users::God) de modérer les signalements d'offres inappropriées effectués par les utilisateurs.

## Fonctionnalités

### 1. Interface de modération

- **Accès** : Uniquement pour les utilisateurs de type `Users::God`
- **URL** : `/signalements/:id/moderer`
- **Depuis RailsAdmin** : Bouton "Modérer" dans la liste des signalements

### 2. Actions de modération disponibles

1. **Rejeter le signalement**
   - Le signalement est considéré comme infondé
   - L'offre reste visible et publiée
   - Aucune action n'est prise sur l'offre

2. **Masquer temporairement l'offre**
   - L'offre est dépubliée (published_at = nil)
   - L'offre peut être republiée après correction
   - Un message peut être envoyé à l'annonceur

3. **Supprimer définitivement l'offre**
   - L'offre est soft-deleted (discarded)
   - L'offre n'est plus visible sur la plateforme
   - Un message peut être envoyé à l'annonceur

### 3. Champs du formulaire

- **Modérateur** (automatique)
  - Le current_user (admin connecté) est automatiquement enregistré comme modérateur
  - Affiché dans une alerte d'information au début du formulaire
  
- **Action de modération** (obligatoire)
  - Choix entre rejeter, masquer ou supprimer
  
- **Message à l'annonceur** (optionnel)
  - Envoyé uniquement si action = masquer ou supprimer
  - Explique la raison de la modération
  
- **Commentaire interne** (optionnel)
  - Note interne non transmise à l'annonceur
  - Pour justifier/contextualiser la décision
  
- **Date de décision** (automatique)
  - Enregistrée automatiquement au moment de la validation

## Workflow

1. Un utilisateur signale une offre via le bouton "Signaler" sur la page d'une offre
2. Le signalement apparaît dans RailsAdmin > Signalements
3. Un administrateur clique sur "Modérer" pour accéder au formulaire
4. L'administrateur consulte :
   - Les détails du signalement (motif, description)
   - Les informations sur l'offre concernée
5. L'administrateur remplit le formulaire de modération
6. Selon l'action choisie, le système :
   - Met à jour le statut du signalement
   - Applique l'action sur l'offre (masquer/supprimer)
   - (TODO) Envoie un email à l'annonceur si applicable

## Modèle de données

### Nouveaux champs dans `inappropriate_offers`

```ruby
moderator_id             # integer    - Référence vers users (le modérateur)
moderation_action        # enum       - Action prise (rejeter/masquer/supprimer)
message_to_offerer       # text       - Message envoyé à l'annonceur
decision_date            # datetime   - Date de la décision
internal_comment         # text       - Commentaire interne
```

### Relations

```ruby
belongs_to :moderator, class_name: 'User', optional: true
```

## Scopes disponibles

```ruby
InappropriateOffer.moderated           # Signalements déjà modérés
InappropriateOffer.pending_moderation  # Signalements en attente
```

## Méthodes disponibles

```ruby
inappropriate_offer.moderated?          # => true/false
inappropriate_offer.pending_moderation? # => true/false
```

## TODO / Améliorations futures

1. Implémenter l'envoi d'email à l'annonceur
   - Créer `OfferModerationMailer`
   - Template d'email pour masquage
   - Template d'email pour suppression

2. Ajouter des statistiques de modération
   - Nombre de signalements traités par modérateur
   - Temps moyen de traitement
   - Répartition des actions prises

3. Système de notification
   - Notifier l'annonceur de la décision
   - Notifier le signaleur de la suite donnée

4. Historique des modérations
   - Pouvoir revoir les décisions passées
   - Log des changements

## Migration

Pour appliquer les changements en base de données :

```bash
rails db:migrate
```

La migration `20251105120000_add_moderation_fields_to_inappropriate_offers.rb` :
- Crée le type enum PostgreSQL `moderation_action_type` avec les valeurs 'rejeter', 'masquer', 'supprimer'
- Ajoute la référence `moderator_id` vers la table `users` avec foreign key
- Ajoute les colonnes : `moderation_action`, `message_to_offerer`, `decision_date`, `internal_comment`

