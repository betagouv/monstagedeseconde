# API V2

To publish internship offers on the [1élève1stage](https://1eleve1stage.education.gouv.fr/) platform, an API is available for:

- Associations  
- Local authorities  
- Ministries  
- Partners

This REST API allows the following operations:

- Create an internship offer on 1élève1stage  
- Update an internship offer  
- Delete an internship offer  
- Retrieve your internship offers  
- Search internship offers

## Table of Contents

- [Environments](#environments)  
- [Authentication](#authentication)  
- [Data Structures & Repositories](#data-structures--repositories)  
  - [Swagger](#swagger)  
  - [Internship Offers](#internship-offers)  
  - [Industry Sectors](#industry-sectors)  
- [Error Handling](#error-handling)  
- [Endpoints](#endpoints)  
  - [Create Offer](#create-offer)  
  - [Get My Offers](#get-my-offers)  
  - [Search Offers](#search-offers)  
  - [Update Offer](#update-offer)  
  - [Delete Offer](#delete-offer)  
- [Getting Started & Examples](#getting-started--examples)

---

## Environments

The API is available at `/api/v2` in both pre-production and production:

- Pre-production: `https://staging.1eleve1stage.education.gouv.fr/api/v2`  
- Production: `https://1eleve1stage.education.gouv.fr/api/v2`

---

## Authentication

**Only authorized actors are allowed to use the API.**

To get access, please **send a request by email** ([support](mailto:contact@1eleve1stage.education.gouv.fr)).

Once your account is created, you will be able to retrieve your token via the web interface. Tokens differ between pre-production and production.

Use the following HTTP header:  
`Authorization: Bearer {token}`

Rate limit: **100 requests per minute** (429 error if exceeded).

### Retrieve Authentication Token

Tokens are JWTs valid for 24 hours.

**Endpoint**: `/auth/login`  
**Method**: `POST`

#### Request Body

* **email** *(string, required)*
* **password** *(text, required)*


``` bash
curl -H "Content-Type: application/json" -X POST -d '{"email": "test@example.com", "password": "password123$-K"}' https://1eleve1stage.education.gouv.fr/api/v2/
```

Response example :
``` json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTc5MzIwMzksInN1YiI6IjEifQ.6874687468746874687468746874687468746874"
}
```

# Data Structures and Repositories

## Internship Offers

The internship offers described below are intended for **quatrième**, **troisième** et **seconde générale et technologique** students :
```
{
  internship_offer: {
    title: Title of the internship offer
    description: Description of the internship offer
    employer_name: Name of the company offering the internship
    employer_description: Description of the company offering the internship
    employer_website: Website link to the company offering the internship

    coordinates: Geographical coordinates of the internship location
    street: Street name where the internship takes place
    zipcode: Postal code of the internship location
    city: City where the internship takes place

    weeks: List of weeks during which the offer is available, see reference *(1)
    sector_uuid: Unique identifier of the sector, see reference *(2)
    grades: List of school grades for which the offer is available, see reference *(3)

    remote_id: Unique identifier from the operator | local authority | association side
    permalink: Redirect link to the unique page on the operator | local authority | association website
    max_candidates: Maximum number of candidates allowed for this internship
    published_at: Date the offer was published
    is_public: Public or private sector
  }
}
```

### <a name="ref-weeks"></a>
## Weeks
Since internships follow a weekly work cycle (Monday to Friday), this information is encoded according to the [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_week_date).

Example: 2025-W20 corresponds to:
* Year: 2025  
* Week number: 20, from May 12 to May 18, 2025

Example of the expected format in our API:

```
internship_offer.weeks: ["2025-W20", "2025-W21", "2025-W22"]
```


### <a name="ref-sectors"></a>
## Activity Sectors

The API requires an associated activity sector as a mandatory parameter for an offer. Below is the *list* along with their **unique identifiers**.

* *Agriculture*: **s51**  
* *Agro-equipment*: **s1**  
* *Architecture, urban planning and landscape*: **s2**  
* *Army - Defense*: **s3**  
* *Art and design*: **s4**  
* *Artisan crafts*: **s5**  
* *Performing arts*: **s6**  
* *Audiovisual*: **s7**  
* *Automotive*: **s8**  
* *Banking and insurance*: **s9**  
* *Construction and public works (BTP)*: **s10**  
* *Well-being*: **s11**  
* *Commerce and retail*: **s12**  
* *Communication*: **s13**  
* *Accounting, management, human resources*: **s14**  
* *Consulting and auditing*: **s15**  
* *Aerospace, railway and naval construction*: **s16**  
* *Culture and heritage*: **s17**  
* *Law and justice*: **s18**  
* *Publishing, bookshops, libraries*: **s19**  
* *Electronics*: **s20**  
* *Energy*: **s21**  
* *Education*: **s22**  
* *Environment*: **s23**  
* *Wood industry*: **s24**  
* *Public service*: **s25**  
* *Hospitality and catering*: **s26**  
* *Real estate, property transactions*: **s27**  
* *Food industry*: **s28**  
* *Chemical industry*: **s29**  
* *Industry, industrial engineering*: **s30**  
* *IT and networks*: **s31**  
* *Video games*: **s32**  
* *Journalism*: **s33**  
* *Logistics and transportation*: **s34**  
* *Maintenance*: **s35**  
* *Marketing, advertising*: **s36**  
* *Mechanics*: **s37**  
* *Craft trades*: **s38**  
* *Fashion*: **s39**  
* *Paper and cardboard*: **s40**  
* *Paramedical*: **s41**  
* *Research*: **s42**  
* *Healthcare*: **s43**  
* *Security*: **s44**  
* *Postal services*: **s45**  
* *Social work*: **s46**  
* *Sports*: **s47**  
* *Tourism*: **s48**  
* *Translation and interpreting*: **s49**  
* *Glass, concrete, ceramics*: **s50**

Example of what we expect in our API as a UUID:

```
internship_offer.sector_uuid: "s33"
```

### <a name="ref-grades"></a>
## School Grades
Internship offers can be targeted at three different school grades: 8th grade, 9th grade, and 10th grade.  
Here are the unique identifiers associated with each grade:
* 8th grade: **quatrieme**
* 9th grade: **troisieme**
* 10th grade: **seconde**

Please note: it is **impossible** to pair **seconde** with either **troisieme** or **quatrieme**.

Example of what we expect in our API:
```
internship_offer.grades: ['troisieme', 'quatrieme']
```
or
```
internship_offer.grades: ['seconde']
```

### <a name="ref-daily-hours"></a>
## Daily Hours
As internships take place over a Monday-to-Friday week, it is possible to specify the hours for each day as follows:

```
{ DAY: [START_TIME, END_TIME] }
```

Example of what we expect in our API:
```
internship_offer.daily_hours: { "lundi": ["8:30";"17:00"], "mardi": ["8:30";"17:00"], "mercredi": ["8:30";"17:00"], "jeudi": ["8:30";"17:00"], "vendredi": ["8:30";"17:00"]}
```

# Error Handling
Request errors will be indicated via an HTTP status code > 400.

For each request, the following errors may occur:

- **400, Bad Request**: Malformed or missing query parameters.  Example: Sector not provided when creating an offer  
- **401, Unauthorized**: Invalid token  
- **403, Forbidden**: You do not have permission to perform this request. Example: Attempting to edit an offer that does not belong to you  
- **422, Unprocessable Entity**: Incorrect payload (the request cannot be processed because the format is invalid) or invalid data  
- **429, Too Many Requests**: The number of requests has exceeded the limit of 100 per minute  

- **500, Internal Server Error**: Service unavailable

In addition to these general errors, request-specific errors will be detailed for each endpoint.


# Endpoints

### <a name="ref-create-internship-offer"></a>
## Create an Internship Offer


**url**: ```#{baseURL}/internship_offers```

**method**: POST

*Body parameters:*

* **internship_offer.title** *(string, required* ≤ 150 characters)  
* **internship_offer.description** *(text, required* ≤ 500 characters)  
* **internship_offer.employer_name** *(string, required* ≤ 150 characters)  
* **internship_offer.employer_description** *(string, required* ≤ 275 characters)  
* **internship_offer.employer_website** *(string, optional* ≤ 560 characters)  
* **internship_offer.coordinates** *(object/geography, optional)*: `{ "latitude": 1, "longitude": 1 }`  
* **internship_offer.street** *(text, optional* ≤ 500 characters)  
* **internship_offer.zipcode** *(string, required* ≤ 5 characters)  
* **internship_offer.city** *(string, required* ≤ 50 characters)  
* **internship_offer.sector_uuid** *(integer, required)*  
* **internship_offer.lunch_break** *(string, optional)*: lunch break details  
* **internship_offer.daily_hours** *(object, optional)*: Daily schedule. e.g.,  `{"lundi": ["9:00", "16:00"], "mardi": ["9:00", "16:00"], "mercredi": ["9:00", "16:00"], "jeudi": ["9:00", "16:00"], "vendredi": ["9:00", "16:00"]}`  
* **remote_id** *(string, required)*: unique identifier from the operator | local authority | association side  
* **permalink** *(url, required* ≤ 200 characters)  
* **max_candidates** *(integer)*  
* **is_public** *(boolean, optional)*: `true` | `false`  
* **lunch_break** *(text, optional between 11 and 500 characters)*  
* **weeks** *(array, required)*: the weeks during which the offer is available, see [reference](#ref-weeks)


### Curl example

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

- **409, Conflict**: An offer with the same ```remote_id``` already exists

### <a name="ref-index-internship-offer"></a>
## Retrieve My Offers

**url**: ```#{baseURL}/internship_offers```

**method**: GET

### Example curl

``` bash
curl -H "Authorization: Bearer $API_TOKEN" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -vvv \
     $ENV/api/internship_offers
```

### Errors

- **409, Conflict**: An offer with the same ```remote_id``` already exists

### <a name="ref-search-internship-offer"></a>
## Search Internship Offers

**url**: ```#{baseURL}/internship_offers/search```

**method**: GET

*URL parameters:*

* **latitude** *(float, optional)*: 1  
* **longitude** *(float, optional)*: 1  
* **radius** *(integer, optional)*: search radius in meters  
* **keyword** *(string, optional)*: keywords to search in the title and description of the offers

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
## Update an Internship Offer

**url**: ```#{baseURL}/internship_offers/#{remote_id}```

**method**: PATCH

*URL parameters:*

* **remote_id** *(string, required)*  
* **internship_offer.title** *(string)*  
* **internship_offer.description** *(text, ≤ 500 characters)*  
* **internship_offer.employer_name** *(string)*  
* **internship_offer.employer_description** *(string, ≤ 275 characters)*  
* **internship_offer.employer_website** *(string)*  
* **internship_offer.coordinates** *(object/geography)*: `{ "latitude": 1, "longitude": 1 }`  
* **internship_offer.street** *(text)*  
* **internship_offer.zipcode** *(string)*  
* **internship_offer.city** *(string)*  
* **internship_offer.sector_uuid** *(integer)*  
* **permalink** *(url)*  
* **max_candidates** *(integer)*  
* **is_public** *(boolean, optional)*: `true` | `false`  
* **weeks** *(array)*: the weeks during which the offer is available, see [reference](#ref-weeks)  
* **published_at** *(datetime.iso8601(0))*: see [reference](https://ruby-doc.org/stdlib-2.6.1/libdoc/date/rdoc/DateTime.html#method-i-iso8601)

Note: To unpublish an offer, set the `published_at` parameter to `null`.

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

- **404, Not Found**: No offer was found with the specified ```remote_id```  
- **422, Unprocessable Entity**: No parameters were provided for the update

### <a name="ref-destroy-internship-offer"></a>
## Delete an Internship Offer

**url**: ```#{baseURL}/internship_offers/#{remote_id}```

**method**: DELETE

*URL parameters:*

* **remote_id** *(string, required)*

### Curl example

``` bash
curl -H "Authorization: Bearer foobarbaz" \
     -H "Accept: application/json" \
     -X DELETE \
     -vvv \
     https://1eleve1stage.education.gouv.fr/api/internship_offers/#{remote_id...}
```

### Errors

- 404, Not Found. No offer was found with the specified ```remote_id```
