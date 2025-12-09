module Presenters
  class Corporation
    include PhoneComputation
    # include Rails.application.routes.url_helpers
    # include ActionView::Helpers::UrlHelper
    attr_reader :corporation
    delegate :employer_name, to: :corporation
    delegate :siret, to: :corporation
    delegate :employer_address, to: :corporation
    delegate :phone, to: :corporation
    delegate :city, to: :corporation
    delegate :zipcode, to: :corporation
    delegate :street, to: :corporation
    delegate :internship_city, to: :corporation
    delegate :internship_zipcode, to: :corporation
    delegate :internship_street, to: :corporation
    delegate :internship_phone, to: :corporation
    delegate :tutor_name, to: :corporation
    delegate :tutor_role_in_company, to: :corporation
    delegate :tutor_email, to: :corporation

    def tutor_phone
      phone_presentation_grouped_by_twos(light_phone_presentation(corporation.tutor_phone))
    end

    def initialize(corporation)
      @corporation = corporation
    end
  end
end