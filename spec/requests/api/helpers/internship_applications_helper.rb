module InternshipApplicationsHelper
  def internship_application_schema
    {
    type: :object,
    properties: {
      id: {
        type: :integer,
        example: 1
      },
      uuid: {
        type: :string,
        format: :uuid,
        example: "550e8400-e29b-41d4-a716-446655440000"
      },
      student_id: {
        type: :integer,
        example: 1
      },
      aasm_state: {
        type: :string,
        example: "submitted",
        maxLength: 100
      },
      submitted_at: {
        type: :string,
        format: :'date-time',
        example: "2023-03-15T10:00:00Z"
      },
      student_email: {
        type: :string,
        format: :email,
        maxLength: 100,
        example: "jean.dupont@example.com"
      },
      student_address: {
        type: :string,
        maxLength: 300,
        example: "12 rue de la paix, 75001 Paris"
      },
      student_phone: {
        type: :string,
        maxLength: 20,
        example: "+330612345678"
      },
      internship_offer_id: {
        type: :integer,
        example: 1
      },
      motivation: {
        type: :string,
        maxLength: 1500,
        example: "Je souhaite faire ce stage pour découvrir le métier de développeur"
      },
      legal_representative_full_name: {
        type: :string,
        maxLength: 150,
        example: "Jean Dupont"
      },
      legal_representative_email: {
        type: :string,
        format: :email,
        maxLength: 109,
        example: "jean.dupont@example.com"
      },
      legal_representative_phone: {
        type: :string,
        maxLength: 50,
        example: "+330612345678"
      },
      weeks: {
        type: :array,
        items: {
          '$ref': '#/components/schemas/Week'
        },
        example: [
          {
            id: 755,
            label: "Semaine du 15 juin au 19 juin",
            selected: false
          },
          {
            id: 756,
            label: "Semaine du 22 juin au 26 juin",
            selected: false
          }
        ]
      },
      createdAt: {
        type: :string,
        format: :'date-time',
        example: "2025-03-04T10:15:00Z"
      },
      updatedAt: {
        type: :string,
        format: :'date-time',
        example: "2025-03-04T10:15:00Z"
      }
    },
    description: "Candidature à une offre de stage"
  }
  end
end