module Presenters
  class Corporation
    include PhoneComputation
    # include Rails.application.routes.url_helpers
    # include ActionView::Helpers::UrlHelper
    attr_reader :corporation

    delegate :multi_corporation_id, to: :corporation
    delegate :siret, to: :corporation
    delegate :sector_id, to: :corporation

    delegate :corporation_name, to: :corporation
    delegate :corporation_address, to: :corporation
    delegate :corporation_city, to: :corporation
    delegate :corporation_zipcode, to: :corporation
    delegate :corporation_street, to: :corporation

    delegate :internship_city, to: :corporation
    delegate :internship_zipcode, to: :corporation
    delegate :internship_street, to: :corporation
    delegate :internship_phone, to: :corporation
    delegate :internship_coordinates, to: :corporation

    delegate :tutor_name, to: :corporation
    delegate :tutor_role_in_company, to: :corporation
    delegate :tutor_email, to: :corporation
    delegate :tutor_phone, to: :corporation

    delegate :employer_name, to: :corporation
    delegate :employer_role, to: :corporation
    delegate :employer_email, to: :corporation
    delegate :employer_phone, to: :corporation
    
    delegate :coordinator, to: :corporation

    delegate :access_token, to: :corporation

    def tutor_phone
      phone_presentation_grouped_by_twos(light_phone_presentation(corporation.tutor_phone))
    end

    def internship_full_address
      [
        internship_street,
        internship_zipcode,
        internship_city
      ].compact.join(' ')
    end

    def initialize(corporation)
      @corporation = corporation
    end
  end
end