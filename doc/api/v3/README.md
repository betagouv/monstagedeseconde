# API V3 1 ELEVE, 1 STAGE

L'API V3 expose une version JSON:API des ressources nécessaires aux partenaires 1élève1stage.  
Les exemples ci-dessous supposent les environnements suivants :

- Préproduction : `https://staging.1eleve1stage.education.gouv.fr/api/v3`

L'authentification reste basée sur un JWT obtenu via `POST /api/v3/auth/login` et transmis dans l'en-tête `Authorization: Bearer <token>`.

## Table des matières

- [Authentification](#authentification)
- [Endpoints](#endpoints)
  - [GET /me – Profil de l'utilisateur courant](#ref-me)
  - [GET /internship_offers/:id/internship_applications/new – Formulaire de candidature](#ref-new-internship-application)
  - [POST /internship_offers/:id/internship_applications – Création de candidature](#ref-create-internship-application)
  - [GET /internship_applications – Toutes les candidatures](#ref-index-internship-applications)
  

## Authentification

```http
POST /api/v3/auth/login
Content-Type: application/json

{
  "email": "operator@example.com",
  "password": "SuperSecret42$"
}
```

Réponse :

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": 123,
  "issued_at": "2025-03-01T09:30:00Z"
}
```

Utilisez la valeur `attributes.token` dans l'en-tête `Authorization`.

## Endpoints

### GET `/me` – Profil de l'utilisateur {#ref-me}

Retourne les informations de l'utilisateur authentifié.  
Disponible pour toutes les classes d'utilisateurs (élève, employeur, opérateur…).

```http
GET /api/v3/me
Authorization: Bearer <token>
Accept: application/vnd.api+json
```

#### Réponse

```json
{
  "type": "user",
  "id": "123",
  "email": "student@example.com",
  "first_name": "Camille",
  "last_name": "Martin",
  "role": "student",
  "phone": "+33601020304",
  "school_id": 87
}
```

Attributs retournés :

| Champ        | Description                                                   |
|--------------|---------------------------------------------------------------|
| `email`      | Adresse email de connexion                                    |
| `first_name` | Prénom                                                        |
| `last_name`  | Nom de famille                                                |
| `role`       | Type fonctionnel (`student`, `employer`, `user_operator`, …)  |
| `phone`      | (optionnel) numéro de téléphone si disponible                 |
| `school_id`  | (optionnel) identifiant d'établissement pour les élèves       |
| `operator_id`| (optionnel) identifiant opérateur pour les comptes opérateurs |

En cas d'absence ou d'invalidité de token, l'API renvoie :

```json
{ 
  [
    "status": "401",
    "code": "UNAUTHORIZED",
    "detail": "wrong api token"
  ]
}
```

## Formulaire de candidature {#ref-new-internship-application}

**url** : ```#{baseURL}/internship_offers/:internship_offer_id/internship_applications/nouveau```

**method** : GET

*Paramètres d'url* :

* **internship_offer_id** *(integer, required)* : L'identifiant de l'offre de stage

**Note** : Cette API nécessite une authentification en tant qu'élève (Users::Student). Les opérateurs et autres types d'utilisateurs ne peuvent pas créer de candidatures via l'API.

### Exemple curl

``` bash
curl -H "Authorization: Bearer $API_TOKEN" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X GET \
     -vvv \
     $ENV/api/v3/internship_offers/123/internship_applications/nouveau
```

### Réponse en cas de succès (201 Created)

``` json
{
  "student_phone": null,
  "student_email": "yvan@email.fr",
  "representative_full_name": null,
  "representative_email": null,
  "representative_phone": null,
  "motivation": "",
  "weeks": [
    {
        "id": 168,
        "label": "Semaine du 16 mars au 20 mars",
        "selected": false
    },
    {
        "id": 169,
        "label": "Semaine du 23 mars au 27 mars",
        "selected": false
    }
  ]
}
```

#### Attributs retournés

| Champ                      | Description                                                                 |
|----------------------------|-----------------------------------------------------------------------------|
| `student_phone`            | Numéro de téléphone de l'élève (ou `null` si non renseigné)                 |
| `student_email`            | Email de l'élève                                                            |
| `representative_full_name` | Nom complet du représentant légal                                           |
| `representative_email`     | Email du représentant légal                                                 |
| `representative_phone`     | Téléphone du représentant légal                                             |
| `motivation`               | Lettre de motivation préremplie (vide par défaut)                           |
| `weeks[].id`               | Identifiant interne de la semaine                                           |
| `weeks[].label`            | Libellé lisible (ex. “Semaine du 16 mars au 20 mars”)                       |
| `weeks[].selected`         | Booléen indiquant si la semaine est déjà sélectionnée pour l'élève          |

#### Gestion des erreurs

| Code | Description                                    | Exemple                                                                                                                                          |
|------|------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| 401  | Jeton manquant ou invalide                     | ```{["status": "401", "code": "UNAUTHORIZED", "detail": "wrong api token"}]```                 |
| 403  | L'utilisateur authentifié n'est pas un élève   | ```{["status": "403", "code": "FORBIDDEN", "detail": "Only students can apply for internship offers"}]``` |
| 404  | Offre introuvable                              | ```{["status": "404", "code": "NOT_FOUND", "detail": "Internship offer not found"}]```        |


## Créer une candidature {#ref-create-internship-application}

**url** : `#{baseURL}/internship_offers/:internship_offer_id/internship_applications`

**method** : POST

*Paramètres d'url* :

* **internship_offer_id** *(integer, required)* : L'identifiant de l'offre de stage

**Payload JSON** (`internship_application`):

| Champ                                   | Type     | Obligatoire | Description                                                        |
|-----------------------------------------|----------|-------------|--------------------------------------------------------------------|
| `student_phone`                         | string   | oui         | Numéro de l'élève (format international accepté)                   |
| `student_email`                         | string   | oui         | Email de l'élève                                                   |
| `week_ids`                              | array    | oui         | Tableau d'identifiants de semaines sélectionnées                  |
| `motivation`                            | string   | oui         | Lettre de motivation                                               |
| `student_address`                       | string   | oui         | Adresse postale de l'élève                                         |
| `student_legal_representative_full_name`| string   | oui         | Nom complet du représentant légal                                  |
| `student_legal_representative_email`    | string   | oui         | Email du représentant légal                                        |
| `student_legal_representative_phone`    | string   | oui         | Téléphone du représentant légal                                    |

Exemple :

```json
{
  "student_phone": "06 11 22 33 44",
  "student_email": "eleve@example.com",
  "week_ids": [168, 169],
  "motivation": "Je suis très motivé pour ce stage.",
  "student_address": "10 rue de Paris, 91000 Évry",
  "student_legal_representative_full_name": "Jean Dupont",
  "student_legal_representative_email": "parent@example.com",
  "student_legal_representative_phone": "06 12 34 56 78"
}
```

### Réponse en cas de succès (201 Created)

```json
{
  "uuid": "6b56c...",
  "internship_offer_id": 123,
  "student_id": 42,
  "state": "submitted",
  "submitted_at": "2025-03-04T10:15:00Z",
  "motivation": "Je suis très motivé pour ce stage.",
  "student_phone": "+33611223344",
  "student_email": "eleve@example.com",
  "student_address": "10 rue de Paris, 91000 Évry",
  "student_legal_representative_full_name": "Jean Dupont",
  "student_legal_representative_email": "parent@example.com",
  "student_legal_representative_phone": "+33612345678",
  "weeks": [
    {
      "id": 168,
      "label": "Semaine du 16 juin au 20 juin",
      "selected": true
    },
    {
      "id": 169,
      "label": "Semaine du 23 juin au 27 juin",
      "selected": true
    }
  ],
  "createdAt": "2025-03-04T10:15:00Z",
  "updatedAt": "2025-03-04T10:15:00Z"
  }
}
```

#### Gestion des erreurs

| Code | Description                                              | Exemple                                                                                                  |
|------|----------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| 400  | Paramètre requis manquant                                | ```[{"status":"400","code":"MISSING_PARAMETER","detail":"Missing required parameter: week_ids"}]``` |
| 401  | Jeton manquant ou invalide                               | ```[{"status":"401","code":"UNAUTHORIZED","detail":"wrong api token"}]```                     |
| 403  | L'utilisateur authentifié n'est pas un élève             | ```[{"status":"403","code":"FORBIDDEN","detail":"Only students can apply for internship offers"}]``` |
| 404  | Offre introuvable                                        | ```[{"status":"404","code":"NOT_FOUND","detail":"Internship offer not found"}]```             |
| 422  | Erreur de validation (format de téléphone, email, …)     | ```[{"status":"422","code":"VALIDATION_ERROR","detail":"Student phone is invalid"}]```        |



## Récupérer les candidatures d'un élève {#ref-index-internship-applications}

**url** : ```#{baseURL}/internship_applications```

**method** : GET

**Note** : Cette API nécessite une authentification en tant qu'élève (Users::Student). Retourne uniquement les candidatures de l'élève authentifié sans pagination.

### Exemple curl

``` bash
curl -H "Authorization: Bearer $API_TOKEN" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X GET \
     -vvv \
     $ENV/api/v3/internship_applications
```

### Réponse en cas de succès (200 OK)

``` json
{

  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "student_id": 456,
  "internship_offer_id": 789,
  "employer_name": "Ministère de l'Éducation Nationale",
  "internship_offer_title": "Stage en communication",
  "internship_offer_address": "110 rue de Grenelle, 75007 Paris",
  "state": "submitted",
  "submitted_at": "2025-03-15T10:30:00Z",
  "motivation": "Je suis très motivé pour ce stage...",
  "student_phone": "+33601020304",
  "student_email": "student@example.com",
  "student_address": "123 rue de la République, 75001 Paris",
  "student_legal_representative_full_name": "Jean Dupont",
  "student_legal_representative_email": "parent@example.com",
  "student_legal_representative_phone": "0612345678",
  "weeks": [
    {
      "id": 168,
      "label": "Semaine du 16 juin au 20 juin",
      "selected": true
    },
    {
      "id": 169,
      "label": "Semaine du 23 juin au 27 juin",
      "selected": true
    }
  ],
  "createdAt": "2025-03-15T10:30:00Z",
  "updatedAt": "2025-03-15T10:30:00Z"
}

```

#### Attributs retournés

| Champ                                    | Description                                                      |
|------------------------------------------|------------------------------------------------------------------|
| `uuid`                                   | Identifiant unique universel de la candidature                  |
| `student_id`                            | Identifiant de l'élève candidat                                |
| `internship_offer_id`                   | Identifiant de l'offre de stage                                |
| `employer_name`                         | Nom de l'employeur proposant le stage                          |
| `internship_offer_title`                | Titre de l'offre de stage                                      |
| `internship_offer_address`              | Adresse complète du lieu de stage                              |
| `state`                                 | État de la candidature (`submitted`, `approved`, `rejected`, etc.) |
| `submitted_at`                          | Date de soumission au format ISO 8601                         |
| `motivation`                            | Lettre de motivation de l'élève                               |
| `student_phone`                         | Téléphone de l'élève                                           |
| `student_email`                         | Email de l'élève                                               |
| `student_address`                       | Adresse de l'élève                                             |
| `student_legal_representative_full_name`| Nom complet du représentant légal                              |
| `student_legal_representative_email`    | Email du représentant légal                                   |
| `student_legal_representative_phone`    | Téléphone du représentant légal                               |
| `weeks`                                 | Tableau d'objets représentant les semaines sélectionnées. Chaque objet contient `id` (identifiant interne), `label` (libellé lisible, ex. "Semaine du 16 juin au 20 juin"), et `selected` (booléen indiquant si la semaine est sélectionnée) |
| `createdAt`                             | Date de création de la candidature                            |
| `updatedAt`                             | Date de dernière modification                                 |

#### Gestion des erreurs

| Code | Description                    | Exemple                                                                                                                          |
|------|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| 401  | Jeton manquant ou invalide     | ```{["status":"401","code":"UNAUTHORIZED","detail":"wrong api token"]}```                                           |








> ℹ️ Les autres endpoints (offres, candidatures, secteurs…) migreront progressivement vers JSON:API au sein de cette V3. Cette page sera mise à jour à chaque ajout.

