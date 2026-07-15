# frozen_string_literal: true

module Users
  class Employer < User
    include EmployerAdmin
    include Signatorable
    include Teamable
    include PdfToPngAttachable

    GRACE_PERIOD = 2.years

    has_one_attached :header_logo
    has_one_attached :signature_stamp

    validates :employer_role,
              presence: true,
              length: { minimum: 3, maximum: 150 }
    validates :header_logo,
              content_type: {
                in: ['image/jpeg', 'image/png'],
                message: 'doit être au format JPEG ou PNG'
              },
              size: {
                less_than: 2.megabytes,
                message: 'doit être inférieur à 2 Mo'
              },
              if: -> { header_logo.attached? }
    validates :signature_stamp,
              content_type: {
                in: ['image/jpeg', 'image/png', 'application/pdf'],
                message: 'doit être au format JPEG, PNG ou PDF'
              },
              size: {
                less_than: 5.megabytes,
                message: 'doit être inférieure à 5 Mo'
              },
              if: -> { signature_stamp.attached? }

    pdf_to_png_attachable :signature_stamp

    def custom_dashboard_path
      return custom_candidatures_path if internship_applications.submitted.any?

      url_helpers.dashboard_internship_offers_path
    end

    def custom_candidatures_path(parameters = {})
      url_helpers.dashboard_candidatures_path(parameters)
    end

    def custom_agreements_path
      url_helpers.dashboard_internship_agreements_path
    end

    def dashboard_name
      'Mon tableau de bord'
    end

    def account_link_name
      'Mon compte'
    end

    def employer? = true
    def agreement_signatorable? = true

    def signatory_role
      Signature.signatory_roles[:employer]
    end

    def presenter
      Presenters::Employer.new(self)
    end

    def after_confirmation
      super
    end

    def password_complexity
      return if persisted? && created_at < Date.new(2024, 8, 1)

      super
    end
  end
end
