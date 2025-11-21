require 'rails_helper'
require_relative  'requests/api/helpers/internship_applications_helper'
include InternshipApplicationsHelper
require_relative  'requests/api/helpers/internship_offers_helper'
include InternshipOffersHelper

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  definitions = {
    parameters: {
      internship_offer_query_params: {
        type: :object,
        properties: {
          page: { type: :integer, example: 1 , nullable: true},
          latitude: { type: :number, format: :float, nullable: true,example: 48.8566 },
          longitude: { type: :number, format: :float, nullable: true, example: 2.3522 },
          radius: { type: :integer, example: 10, nullable: true },
          sector_ids: { type: :array, nullable: true, items: { type: :integer},  example: [nil,21, 23] },
          week_ids: { type: :array, items: { type: :integer }, nullable: true, example: [nil, 101, 102] },
          grades: { type: :array, items: { type: :integer, enum: [1,2,3] }, nullable: true, example: [nil,  2, 3] }
        }
      }
    }
  }

  config.openapi_specs = {
    'api/v3/swagger.yaml' => {  
      openapi: '3.0.0',
      info: {
        title: 'API V3',  # Updated title
        version: '1.0.0',
        description: 'API de backend pour https://1eleve1stage.education.gouv.fr/'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000/api/v3',
          description: 'Development server'
        }
      ],
      definitions: definitions,
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          InternshipApplications: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/InternshipApplication'
            }
          },
          InternshipApplication: internship_application_schema,
          InternshipOffers: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/InternshipOffer'
            }
          },
          InternshipOffer: internship_offer_schema,
          InternshipOfferPatch: {
            allOf: [
              {
                type: :object,
                properties: {
                  published_at: {
                    type: :string,
                    format: :'date-time'
                  }
                }
              },
              {
                '$ref': '#/components/schemas/InternshipOffer'
              }
            ],
            description: "Offre de stage à mettre à jour. Pour désactiver une offre, passer le paramètre published_at à null"
          },
          Grade: {
            type: :string,
            enum: ["seconde", "troisieme", "quatrieme"],
            example: "seconde"
          },
          Sector: {
            type: :object,
            properties: {
              id: {
                type: :number,
                example: 1
              },
              sector_uuid: {
                type: :string
              },
              name: {
                type: :string,
                example: "Mode"
              }
            },
            description: "Secteur économique.",
            example: {
              sector_uuid: "s20",
              name: "Mode",
              id: 1
            }
          },
          InternshipApplicationPayload: {
            description: "Candidature à une offre de stage (création)",
            type: :object,
            properties: {
              internship_application: {
                type: :object,
                required: [
                  :student_phone,
                  :student_email,
                  :week_ids,
                  :motivation,
                  :student_address,
                  :student_legal_representative_full_name,
                  :student_legal_representative_email,
                  :student_legal_representative_phone
                ],
                properties: {
                  student_phone: {
                    type: :string,
                    maxLength: 20,
                    example: "+330612345678"
                  },
                  student_email: {
                    type: :string,
                    format: :email,
                    maxLength: 100,
                    example: "eleve@example.com"
                  },
                  week_ids: {
                    type: :array,
                    items: {
                      type: :integer
                    },
                    example: [168, 169]
                  },
                  motivation: {
                    type: :string,
                    maxLength: 1500,
                    example: "Je suis très motivé pour ce stage."
                  },
                  student_address: {
                    type: :string,
                    maxLength: 300,
                    example: "10 rue de Paris, 91000 Évry"
                  },
                  student_legal_representative_full_name: {
                    type: :string,
                    maxLength: 150,
                    example: "Jean Dupont"
                  },
                  student_legal_representative_email: {
                    type: :string,
                    format: :email,
                    maxLength: 109,
                    example: "parent@example.com"
                  },
                  student_legal_representative_phone: {
                    type: :string,
                    maxLength: 20,
                    example: "+330612345678"
                  }
                }
              }
            },
            example: {
              internship_application: {
                "student_phone" => "06 11 22 33 44",
                "student_email" => "eleve@example.com",
                "week_ids" => [168, 169],
                "motivation" => "Je suis très motivé pour ce stage.",
                "student_address" => "10 rue de Paris, 91000 Évry",
                "student_legal_representative_full_name" => "Jean Dupont",
                "student_legal_representative_email" => "parent@example.com",
                "student_legal_representative_phone" => "06 12 34 56 78"
              }
            }
          },
          InternshipApplicationForm: {
            allOf: [
              {
                '$ref': '#/components/schemas/InternshipApplication'
              },
              {
                type: :object,
                properties: {
                  internship_offer_id: {
                    nullable: true
                  },
                  id: {
                    nullable: true
                  },
                  uuid: {
                    nullable: true
                  },
                  createdAt: {
                    nullable: true
                  },
                  updatedAt: {
                    nullable: true
                  },
                  student_address: {
                    nullable: true
                  },
                  aasm_state: {
                    nullable: true
                  },
                  submitted_at: {
                    nullable: true
                  }
                }
              }
            ]
          },
          User: {
            description: "Utilisateur de l'API - données élémentaires",
            type: :object,
            properties: {
              id: {
                type: :integer,
                example: 1
              },
              email: {
                type: :string,
                format: :email,
                example: "user@example.com"
              },
              first_name: {
                type: :string,
                example: "John"
              },
              last_name: {
                type: :string,
                example: "Doe"
              },
              role: {
                type: :string,
                example: "Employer"
              },
              phone: {
                type: :string,
                example: "+330612345678"
              },
              school_id: {
                type: :integer,
                example: 123
              },
              operator_id: {
                type: :integer,
                example: 456
              }
            }
          },
          inline_response_401: {
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "401"
              },
              code: {
                type: :string,
                example: "unauthorized"
              },
              detail: {
                type: :string,
                example: "Wrong api key or invalid token"
              }
            }
          },
          inline_response_403: {
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "403"
              },
              code: {
                type: :string,
                example: "forbidden"
              },
              detail: {
                type: :string,
                example: "The client does not have access rights to the content"
              }
            }
          },
          inline_response_404: {
            description: "The server cannot find the requested resource",
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "404"
              },
              code: {
                type: :string,
                example: "not_found"
              },
              detail: {
                type: :string,
                example: "The server cannot find the requested resource"
              }
            }
          },
          inline_response_406: {
            description: "WebBrowser doesn't find any content that conforms to the criteria given by the user agent.",
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "406"
              },
              code: {
                type: :string,
                example: "not_acceptable"
              },
              detail: {
                type: :string,
                example: "WebBrowser doesn't find any content that conforms to the criteria given by the user agent."
              }
            }
          },
          inline_response_409: {
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "409"
              },
              code: {
                type: :string,
                example: "conflict"
              },
              detail: {
                type: :string,
                example: "This request raises a conflicts with the current state of the server"
              }
            }
          },
          inline_response_422: {
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "422"
              },
              code: {
                type: :string,
                example: "unprocessable_entity"
              },
              detail: {
                type: :string,
                example: "The request was directed at a server that is not able to produce a response."
              }
            }
          },
          inline_response_404_1: {
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "404"
              },
              code: {
                type: :string,
                example: "not_found"
              },
              detail: {
                type: :string,
                example: "Can't find internship_offer with this remote_id"
              }
            }
          },
          inline_response_429: {
            type: :object,
            properties: {
              status: {
                type: :string,
                example: "429"
              },
              code: {
                type: :string,
                example: "too_many_requests"
              },
              detail: {
                type: :string,
                example: "Too many requests in a given amount of time."
              }
            }
          },
          InternshipOffer_coordinates: {
            type: :object,
            properties: {
              latitude: {
                type: :number,
                example: 48.866667
              },
              longitude: {
                type: :number,
                example: 2.333333
              }
            },
            description: "Coordonnées géographiques du lieu de stage"
          },
          InternshipOffer_daily_hours: {
            type: :object,
            properties: {
              lundi: {
                type: :array,
                example: ["9:00", "18:00"],
                items: {
                  type: :string
                }
              },
              mardi: {
                type: :array,
                example: ["9:00", "18:00"],
                items: {
                  type: :string
                }
              },
              mercredi: {
                type: :array,
                example: ["9:00", "18:00"],
                items: {
                  type: :string
                }
              },
              jeudi: {
                type: :array,
                example: ["9:00", "18:00"],
                items: {
                  type: :string
                }
              },
              vendredi: {
                type: :array,
                example: ["9:00", "18:00"],
                items: {
                  type: :string
                }
              }
            },
            description: "Horaires quotidiens de stage"
          },
          Week: {
            type: :object,
            description: "Semaine pendant laquelle l'offre de stage est disponible",
            properties: {
              id: {
                type: :integer,
                example: 218
              },
              label: {
                type: :string,
                example: "Semaine du 4 juin 2024 au 10 juin 2024"
              },
              selected: {
                type: :boolean,
                example: false
              }
            }
          }
        },
        responses: {
          Unauthorized: {
            description: "l'authentification a échoué",
            content: {
              'application/json': {
                schema: {
                  '$ref': '#/components/schemas/inline_response_401'
                }
              }
            }
          }
        },
        requestBodies: {
          InternshipOffer: {
            content: {
              'application/json': {
                schema: {
                  '$ref': '#/components/schemas/InternshipOffer'
                }
              }
            }
          },
          InternshipApplication: {
            content: {
              'application/json': {
                schema: {
                  '$ref': '#/components/schemas/InternshipApplication'
                }
              }
            }
          },
          InternshipOfferPatch: {
            content: {
              'application/json': {
                schema: {
                  '$ref': '#/components/schemas/InternshipOfferPatch'
                }
              }
            }
          }
        }
      }
    }
  }
  config.openapi_format = :yaml
end

# Set format to YAML