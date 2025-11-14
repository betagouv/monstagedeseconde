# API V3 1 ELEVE, 1 STAGE

L'API V3 expose une version JSON:API des ressources nécessaires aux partenaires 1élève1stage.  
Les exemples ci-dessous supposent les environnements suivants :

- Préproduction : `https://staging.1eleve1stage.education.gouv.fr/api/v3`

L'authentification reste basée sur un JWT obtenu via `POST /api/v3/auth/login` et transmis dans l'en-tête `Authorization: Bearer <token>`.

## Table des matières

- [Authentification](#authentification)
- [Endpoints](#endpoints)
  - [/me – profil de l'utilisateur courant](#ref-me)

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
  "data": {
    "type": "auth-token",
    "id": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "attributes": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user_id": 123,
      "issued_at": "2025-03-01T09:30:00Z"
    }
  }
}
```

Utilisez la valeur `attributes.token` dans l'en-tête `Authorization`.

## Endpoints

### <a name="ref-me"></a> GET `/me` – Profil de l'utilisateur

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
  "data": {
    "type": "user",
    "id": "123",
    "attributes": {
      "email": "student@example.com",
      "first_name": "Camille",
      "last_name": "Martin",
      "role": "student",
      "phone": "+33601020304",
      "school_id": 87
    }
  }
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
  "errors": [
    {
      "status": "401",
      "code": "UNAUTHORIZED",
      "detail": "wrong api token"
    }
  ]
}
```

### <a name="ref-new-internship-application"></a>
## Formulaire de candidature

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
  "data": {
    "type": "internship-application-form",
    "id": "new",
    "attributes": {
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
  }
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
| 401  | Jeton manquant ou invalide                     | ```{"errors": [{ "status": "401", "code": "UNAUTHORIZED", "detail": "wrong api token" }]}```                 |
| 403  | L'utilisateur authentifié n'est pas un élève   | ```{"errors": [{ "status": "403", "code": "FORBIDDEN", "detail": "Only students can apply for internship offers" }]}``` |
| 404  | Offre introuvable                              | ```{"errors": [{ "status": "404", "code": "NOT_FOUND", "detail": "Internship offer not found" }]}```        |


### <a name="ref-create-internship-application"></a>
## Créer une candidature

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
  "internship_application": {
    "student_phone": "06 11 22 33 44",
    "student_email": "eleve@example.com",
    "week_ids": [168, 169],
    "motivation": "Je suis très motivé pour ce stage.",
    "student_address": "10 rue de Paris, 91000 Évry",
    "student_legal_representative_full_name": "Jean Dupont",
    "student_legal_representative_email": "parent@example.com",
    "student_legal_representative_phone": "06 12 34 56 78"
  }
}
```

### Réponse en cas de succès (201 Created)

```json
{
  "data": {
    "type": "internship-application",
    "id": "987",
    "attributes": {
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
      "weeks": ["2025-W12", "2025-W13"],
      "created_at": "2025-03-04T10:15:00Z",
      "updated_at": "2025-03-04T10:15:00Z"
    }
  }
}
```

#### Gestion des erreurs

| Code | Description                                              | Exemple                                                                                                  |
|------|----------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| 400  | Paramètre requis manquant                                | ```{"errors":[{"status":"400","code":"MISSING_PARAMETER","detail":"Missing required parameter: week_ids"}]}``` |
| 401  | Jeton manquant ou invalide                               | ```{"errors":[{"status":"401","code":"UNAUTHORIZED","detail":"wrong api token"}]}```                     |
| 403  | L'utilisateur authentifié n'est pas un élève             | ```{"errors":[{"status":"403","code":"FORBIDDEN","detail":"Only students can apply for internship offers"}]}``` |
| 404  | Offre introuvable                                        | ```{"errors":[{"status":"404","code":"NOT_FOUND","detail":"Internship offer not found"}]}```             |
| 422  | Erreur de validation (format de téléphone, email, …)     | ```{"errors":[{"status":"422","code":"VALIDATION_ERROR","detail":"Student phone is invalid"}]}```        |



> ℹ️ Les autres endpoints (offres, candidatures, secteurs…) migreront progressivement vers JSON:API au sein de cette V3. Cette page sera mise à jour à chaque ajout.

