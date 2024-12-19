# frozen_string_literal: true

module Users
  class Employer < User
    include EmployerAdmin
    include Signatorable
    include Teamable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable,
           :validatable, :confirmable, :trackable,
           :timeoutable, :lockable

    GRACE_PERIOD = 2.years

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
      UpdateHubspotContactJob.perform_later(id)
    end
  end
end
