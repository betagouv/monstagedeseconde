To post offers on the [1élève1stage](https://stagedeseconde.1jeune1solution.gouv.fr/) platform, an API is available for:

* Associations
* Local Authorities
* Ministries
* Partners

This is a REST API that allows the following operations:

* Add an internship offer on 1élève1stage
* Modify an internship offer on 1élève1stage
* Delete an internship offer on 1élève1stage
* Retrieve posted internship offers on 1élève1stage
* Search for internship offers on 1élève1stage

# Table of contents
- [Environments](#environments)
- [Authentication](#authentication)
- [Data Structures and References](#structures-de-données-et-référentiels)
  - [Swagger](#swagger)
  - [Internship Offers](#offres-de-stage)
  - [Activity Sectors](#secteurs-dactivité)
- [Error Management](#gestion-derreurs)
- [Endpoints](#endpoints)
  - [Create an Offer](#ref-create-internship-offer)
  - [Retrieve My Offers](#ref-index-internship-offer)
  - [Search for Offers](#ref-search-internship-offer)
  - [Modify an Offer](#ref-modify-internship-offer)
  - [Delete an Offer](#ref-destroy-internship-offer)
- [Getting Started and Examples](#premiers-pas-et-exemples)


# Environnments
The API is available at /api in both pre-production and production environments, with the following baseURLs:
  * Pre production : https://stagedeseconde.recette.1jeune1solution.gouv.fr/api
  * Production : https://stagedeseconde.1jeune1solution.gouv.fr/api

# Authentication

*The APIs are open only to the concerned stakeholders.*

**Please request an API account via email** ([support](mailto:contact@stagedeseconde.education.gouv.fr)) pour créer un compte API.

Once the account is created, the API token can be retrieved through our web interface. It varies between the pre-production and production environments.

Authentication is done via token using the HTTP header : ```Authorization: Bearer #{token} ```

This token must be included in each request.

Usage is limited to 100 calls per minute; exceeding this will return a 429 error.

### How to Retrieve Your Authentication Token

[Login](https://stagedeseconde.1jeune1solution.gouv.fr/utilisateurs/connexion) with your operator account

![](screenshots/login.png)

From the [My profile](https://stagedeseconde.1jeune1solution.gouv.fr/mon-compte) page, go to the API page.

![](screenshots/logged.png)

From the [API](https://stagedeseconde.1jeune1solution.gouv.fr/mon-compte/api) page, retrieve the token.

![](screenshots/api.png)




# Data Structures and References

## Swagger
To test the API and understand its functionality, a [swagger](https://app-e29a97fc-5386-434f-bf9d-8f813c68f838.cleverapps.io/docs/) is available.

## Internship Offers

The internship offers described below are reserved for general and technological high school classes.

```
{
  internship_offer: {
    title : Title of the internship offer
    description : Description of the internship offer

    employer_name : Name of the company offering the internship
    employer_description : Description of the company offering the internship
    employer_website : Web link to the company's website offering the internship

    coordinates : Geographical coordinates of the internship location
    street : Street name where the internship takes place
    zipcode  : Postal code where the internship takes place
    city : City where the internship takes place

    sector_uuid : Unique identifier of the sectors, see reference *(1)
    period: Duration of the internship (see below)

    remote_id: unique identifier on the operator|community|association side
    permalink: redirection link to the unique site on the operator|community|association side
    max_candidates: number of possible candidates for this internship
    published_at: publication date of the offer
    is_public: Public or private sector
  }
}
```
### <a name="ref-period"></a>
## Internship Period

L'API attend en paramètre obligatoire la durée du stage qui peut être :
* Plein temps - du 17 au 24 juin 2024 : **0**,
* Semaine 1 - du 17 au 21 juin 2024 : **1**,
* Semaine 2 - du 24 au 28 juin 2024 : **2**

The API expects a mandatory parameter for the duration of the internship which can be:
* Full-time - from June 17 to June 24, 2024: **0**,
* Week 1 - from June 17 to June 21, 2024: **1**,
* Week 2 - from June 24 to June 28, 2024: **2**

### <a name="ref-sectors"></a>
## Secteurs d'activité

The API expects a mandatory parameter for an activity sector associated with an offer. Here is the *list* and their **unique identifiers**.

* *Agriculture*: **s51**,
* *Agroéquipement*: **s1**,
* *Architecture, urbanisme et paysage*: **s2**,
* *Armée - Défense*: **s3**,
* *Art et design*: **s4**,
* *Artisanat d'art*: **s5**,
* *Arts du spectacle*: **s6**,
* *Audiovisuel*: **s7**,
* *Automobile*: **s8**,
* *Banque et assurance*: **s9**,
* *Bâtiment et travaux publics (BTP)*: **s10**,
* *Bien-être*: **s11**,
* *Commerce et distribution*: **s12**,
* *Communication*: **s13**,
* *Comptabilité, gestion, ressources humaines*: **s14**,
* *Conseil et audit*: **s15**,
* *Construction aéronautique, ferroviaire et navale*: **s16**,
* *Culture et patrimoine*: **s17**,
* *Droit et justice*: **s18**,
* *Édition, librairie, bibliothèque*: **s19**,
* *Électronique*: **s20**,
* *Énergie*: **s21**,
* *Enseignement*: **s22**,
* *Environnement*: **s23**,
* *Filiere bois*: **s24**,
* *Fonction publique*: **s25**,
* *Hôtellerie, restauration*: **s26**,
* *Immobilier, transactions immobilières*: **s27**,
* *Industrie alimentaire*: **s28**,
* *Industrie chimique*: **s29**,
* *Industrie, ingénierie industrielle*: **s30**,
* *Informatique et réseaux*: **s31**,
* *Jeu vidéo*: **s32**,
* *Journalisme*: **s33**,
* *Logistique et transport*: **s34**,
* *Maintenance*: **s35**,
* *Marketing, publicité*: **s36**,
* *Mécanique*: **s37**,
* *Métiers d'art*: **s38**,
* *Mode*: **s39**,
* *Papiers Cartons*: **s40**,
* *Paramédical*: **s41**,
* *Recherche*: **s42**,
* *Santé*: **s43**,
* *Sécurité*: **s44**,
* *Services postaux*: **s45**,
* *Social*: **s46**,
* *Sport*: **s47**,
* *Tourisme*: **s48**,
* *Traduction, interprétation*: **s49**,
* *Verre, béton, céramique*: **s50**

Example of what we expect, a uuid in our APIs:

```
internship_offer.sector_uuid: "s33"
```

### <a name="ref-daily-hours"></a>
## Daily Hours
Internships take place from Monday to Friday for one week, and it is possible to specify the hours of each day as follows:

```
{ DAY: [START_TIME, END_TIME] }
```

Example of what we expect in our APIs:

```
internship_offer.daily_hours: { "lundi": ["8:30";"17:00"], "mardi": ["8:30";"17:00"], "mercredi": ["8:30";"17:00"], "jeudi": ["8:30";"17:00"], "vendredi": ["8:30";"17:00"]}
```

# Error Management
Request errors will be indicated via an HTTP code > 400.

For each request, the following errors may occur:

- 400, Bad Request: Incorrectly filled request parameters. Example: Sector not specified when creating an offer
- 401, Unauthorized: Invalid token
- 403, Forbidden: Not allowed to perform this request. Example: Modifying an offer that does not belong to you
- 422, Unprocessable Entity: Incorrect payload (unable to process the request as the format does not match). Or the data is not valid
- 429, Too Many Requests: The number of calls has exceeded 100 per minute
- 500, Internal Server Error: Service unavailable

In addition to these general errors, specific errors for each call will be detailed for each one.

# Endpoints

### <a name="ref-create-internship-offer"></a>
## Create an Offer


**url** : ```#{baseURL}/internship_offers```

**method** : POST

*Bbody params:*

* **internship_offer.title** *(string, required)*
* **internship_offer.description** *(text, required *<= 500 characters)
* **internship_offer.employer_name** *(string, required)*
* **internship_offer.employer_description** *(string, required *<= 275 characters)
* **internship_offer.employer_website** *(string, optional)*
* **internship_offer.coordinates** *(object/geography, optional)* : { "latitude" : 1, "longitude" : 1 }
* **internship_offer.street** *(text, optional)*
* **internship_offer.zipcode** *(string, required)*
* **internship_offer.city** *(string, required)*
* **internship_offer.sector_uuid** *(integer, required)*
* **internship_offer.period** *(integer, required)*
* **internship_offer.lunch_break** *(string, optional)*: Details of the lunch break
* **internship_offer.daily_hours** *(object, optional)*: The hours of each day. ex: {"lundi": ['9:00', '16:00], "mardi": ['9:00', '16:00], "mercredi": ['9:00', '16:00], "jeudi": ['9:00', '16:00], "vendredi": ['9:00', '16:00]}
* **remote_id** *(string, required)*: unique identifier on the operator|community|association side
* **permalink** *(url, required)*
* **max_candidates** *(integer)*
* **is_public** *(boolean, optional)*: true|false
* **lunch_break** *(text, optional *<= 500 characters)
* **daily_hours** *(object, optional, 

### Example curl

``` bash
curl -H "Authorization: Bearer $API_TOKEN" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X POST \
     -d '{"internship_offer": {"title":"title","description":"description","employer_website":"http://google.fr","street":"Tour Effeil","zipcode":"75002","city":"Paris","employer_name":"employer_name", "employer_description":"employer_description","remote_id":"test_2","permalink":"https://www.google.fr","sector_uuid": "1ce60ecc-273d-4c73-9b1a-2f5ee14e1bc6", "coordinates":{"latitude":1.0,"longitude":1.0}}}' \
     -vvv \
     $ENV/api/internship_offers
```

### Errors

- 409, Conflict: An offer with the same ```remote_id``` already exists

### <a name="ref-index-internship-offer"></a>
## Retrieve My Offers


**url** : ```#{baseURL}/internship_offers```

**method** : GET

### Example curl

``` bash
curl -H "Authorization: Bearer $API_TOKEN" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -vvv \
     $ENV/api/internship_offers
```

### <a name="ref-search-internship-offer"></a>
## Search for Offers

**url** : ```#{baseURL}/internship_offers/search```

**method** : GET

*URL params**

* **latitude** *(float, optional)* : 1
* **longitude** *(float, optional)* : 1
* **radius** *(integer, optional)* : search radius in meters
* **keyword** *(string, optional)* : keywords to search in the title and description of the offers

### Example curl

``` bash
curl -H "Authorization: Bearer $API_TOKEN" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X GET \
     -d '{"latitude": 44.8624,
          "longitude": -0.5848,
          "radius": 10000,
          "keyword": "avocat"
          }'
     -vvv \
     $ENV/api/internship_offers/search
```


### <a name="ref-modify-internship-offer"></a>
## Modify an Offer


**url** : ```#{baseURL}/internship_offers/#{remote_id}```

**method** : PATCH

*URL params* :

* **remote_id** *(string, required)*
* **internship_offer.title** *(string)*
* **internship_offer.description** *(text,  <= 500 characters)*
* **internship_offer.employer_name** *(string)*
* **internship_offer.employer_description** *(string, <= 275 characters)*
* **internship_offer.employer_website** *(string)*
* **internship_offer.coordinates** *(object/geography)* : { "latitude" : 1, "longitude" : 1 }
* **internship_offer.street** *(text)*
* **internship_offer.zipcode** *(string)*
* **internship_offer.city** *(string)*
* **internship_offer.sector_uuid** *(integer)*
* **internship_offer.period** *(integer)*
* **permalink** *(url)*
* **max_candidates** *(integer)*
* **is_public** *(boolean, optional)*: true|false
* **published_at** *(datetime.iso8601(0))* : see references [reference](https://ruby-doc.org/stdlib-2.6.1/libdoc/date/rdoc/DateTime.html#method-i-iso8601)

Note: Depublication is done by passing null in the published_at parameter

### Example curl

``` bash
curl -H "Authorization: Bearer $API_TOKEN" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X PATCH \
     -d '{"internship_offer": {"title":"Mon offre de stage", "description": "Description..."}}' \
     -vvv \
     $ENV/api/internship_offers/$remote_id
```

### Errors

- 404, Not Found. No offer found with the specified ```remote_id```
- 422, Unprocessable Entity. No parameters specified for modification

### <a name="ref-destroy-internship-offer"></a>
## Delete an Offer
**url** : ```#{baseURL}/internship_offers/#{remote_id}```

**method** : DELETE

*URL params* :

* **remote_id** *(string, required)*

### Example curl

``` bash
curl -H "Authorization: Bearer foobarbaz" \
     -H "Accept: application/json" \
     -X DELETE \
     -vvv \
     https://monstagedetroisieme.fr/api/internship_offers/#{job_irl_id|vvmt_id|myfuture_id|provider_id...}
```

### Erreurs

- 404, Not Found. No offer found with the specified ```remote_id```


# Getting Started and Examples

To test our APIs, we use [shell scripts](https://github.com/betagouv/monstagedeseconde/tree/master/doc/requests/internship_offers/).


This is a simple way to test your token and our APIs.

``` bash
git clone https://github.com/betagouv/monstagedeseconde.git
cd monstagedeseconde
cd doc
cp env.sample env.sh
```

You can now configure your environment (pre-production/production) and your token by editing the ```env.sh``` file

```
set -x

# usage: rename env.sample env.sh

MONSTAGEDESECONDE_ENV=https://stagedeseconde.1jeune1solution.gouv.fr/api
MONSTAGEDESECONDE_TOKEN=foobarbaz
```

## Create an Offer
* example API call: ```./requests/internship_offers/create.sh```
* example response, see: ./output/internship_offers/create/*
* example payload, see: ./input/internship_offers/create.json

## Update an Offer
* example API call: ```./requests/internship_offers/update.sh```
* example response, see: ./output/internship_offers/update/*
* example payload, see: ./input/internship_offers/update.json

## Delete an Offer
* example API call: ```./requests/internship_offers/destroy.sh```
* example response, see: ./output/internship_offers/destroy/*