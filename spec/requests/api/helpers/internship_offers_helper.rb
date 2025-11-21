module InternshipOffersHelper
  def internship_offer_schema
    {
      required: [
        :city,
        :coordinates,
        :employer_name,
        :is_public,
        :max_candidates,
        :remote_id,
        :sector_uuid,
        :street,
        :title,
        :grades,
        :weeks,
        :qpv,
        :rep
      ],
      type: :object,
      properties: {
        remote_id: {
          type: :string,
          maxLength: 60,
          description: "Identifiant de l'offre de stage chez le partenaire",
          example: "A156548-H"
        },
        description: {
          maxLength: 500,
          type: :string,
          description: "Description de l'offre de stage"
        },
        title: {
          type: :string,
          maxLength: 150,
          example: "Stage d'observation du métier de chef de service"
        },
        employer_name: {
          type: :string,
          maxLength: 150,
          example: "BNP Paribas"
        },
        employer_description: {
          maxLength: 275,
          type: :string,
          example: "Créateur de lotions, de parfums et de produits cosmétiques, embaumeur"
        },
        street: {
          type: :string,
          maxLength: 500,
          example: "16 rue de la paix"
        },
        city: {
          type: :string,
          maxLength: 50,
          example: "Paris"
        },
        zipcode: {
          type: :string,
          maxLength: 5,
          example: "75001"
        },
        employer_website: {
          type: :string,
          maxLength: 560,
          example: "http://www.acnee-corporation.fr"
        },
        lunch_break: {
          type: :string,
          maxLength: 500,
          description: "Horaires de pause déjeuner",
          example: "12h-14h"
        },
        daily_hours: {
          '$ref': '#/components/schemas/InternshipOffer_daily_hours'
        },
        coordinates: {
          '$ref': '#/components/schemas/InternshipOffer_coordinates'
        },
        grades: {
          type: :array,
          description: "Liste des classes dont les élèves peuvent postuler à l'offre de stage",
          items: {
            '$ref': '#/components/schemas/Grade'
          }
        },
        permalink: {
          type: :string,
          description: "Site de l'employeur",
          maxLength: 200,
          example: "http://www.stagechezemployeur.fr"
        },
        max_candidates: {
          type: :integer,
          description: "Nombre maximum de candidats pouvant postuler à cette offre de stage sur l'ensemble des semaines proposées",
          example: 1
        },
        is_public: {
          type: :boolean,
          description: "true si l'offre de stage est issue d'une administration publique, false si elle est issue d'une entreprise privée",
          example: true
        },
        sector_uuid: {
          '$ref': '#/components/schemas/Sector'
        },
        rep: {
          type: :boolean,
          description: "true si l'offre de stage est réservée à des collèges en rep ou rep plus",
          example: true
        },
        qpv: {
          type: :boolean,
          description: "true si l'offre de stage est réservée à des établissements en qpv",
          example: true
        },
        weeks: {
          type: :array,
          items: {
            type: :string
          },
          description: "Liste des semaines pendant lesquelles l'offre de stage est disponible",
          example: ["222", "223"]
        }
      },
      description: "offre de stage",
      example: {
        remote_id: "A123-12",
        grades: ['seconde', 'troisieme'],
        city: "Paris",
        coordinates: {
          latitude: 48.866667,
          longitude: 2.333333
        },
        description: "Stage sur le thème de la logistique et de la supply chain",
        employer_description: "Créateur de lotions, de parfums et de produits cosmétiques, embaumeur",
        employer_name: "BNP Paribas",
        title: "Stage d'observation du métier de chef de service",
        lunch_break: "12h-14h",
        zipcode: "75001",
        max_candidates: 1,
        employer_website: "http://www.acnee-corporation.fr",
        sector_uuid: {
          sector_uuid: "s20",
          name: "Mode",
          id: 1
        },
        street: "16 rue de la paix",
        is_public: true,
        rep: false,
        qpv: true,
        weeks: ["311", "312"],
        permalink: "http://www.stagechezemployeur.fr",
        daily_hours: [
          {
            lundi: ["9:00", "18:00"]
          },
          {
            mardi: ["9:00", "18:00"]
          },
          {
            mercredi: ["9:00", "18:00"]
          },
          {
            jeudi: ["9:00", "18:00"]
          },
          {
            vendredi: ["9:00", "18:00"]
          }
        ]
      }
    }
  end
end