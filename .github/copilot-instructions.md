# Pratiques courantes dans ce projet
La version de rails est 8.1

Postgresql est la base de données en version 15
Le fichier représentant la structure de la base de données est db/structure.sql
Le fichier de routes est dans config/routes.rb

Le presenters se trouvent dans libs/presenters. Ils sont utilisées dans les cas où une logique de présentation polluerait le code de la vue

Pattern : Utiliser des Service Objects dans app/services.

Frontend : Utiliser uniquement Stimulus, React ou Turbo. Pas de Vanilla JS global.

Voici les spécificités de code identifiées :

---

**Modèles**
- **STI** sur les utilisateurs (`User` avec sous-types : Student, Employer, God, Operator...) + `StiPreload` concern
- **AASM** pour les state machines (`InternshipApplication`, `InternshipOffer`)
- **Discard** gem pour les soft deletes
- Nombreuses concerns (`Listable`, `Nearbyable`, `Zipcodable`, `Weekable`...)

**Controllers**
- `authorize!` CanCanCan obligatoire sur chaque action
- `before_action` pour rate limiting (Redis), maintenance, contexte école
- Rescue de `CanCan::AccessDenied` avec redirect user-friendly

**Services / Couches métier**
- Services dans services (pas `app/services/`)
- **Builders** dans builders : wrappent la logique de création avec callbacks success/failure
- **Finders** pour l'abstraction des requêtes complexes
- **DTO** dans dto

**Frontend**
- 60+ controllers **Stimulus** dans controllers
- **React** pour SearchSchool, InternshipOfferResults, MultiMap (Leaflet), CountryPhoneSelect
- **View Components** dans components

**Tests**
- Minitest + FactoryBot (factories dans factories)
- Tests système avec Chrome headless + émulation mobile iPhone 6
- Parallélisation sur 12 workers avec 3 retries sur les tests flaky
- WebMock pour les APIs externes, Sidekiq en mode fake

**Jobs**
- Sidekiq + Redis
- Jobs déclenchés dans triggered

**Mailers**
- Base `ApplicationMailer`, spécialisés par rôle (StudentMailer, EmployerMailer...)

**Base de données**
- PostgreSQL 15 + **PostGIS** pour les requêtes géospatiales
- Full-text search avec stemming français
- la structure de la base est dans db/structure.sql

**Sécurité**
- Rate limiting IP dans `ApplicationController`
- Mot de passe : 12+ chars, maj/min/chiffres/spéciaux
- Sentry pour le tracking d'erreurs
- Flipper pour les feature flags