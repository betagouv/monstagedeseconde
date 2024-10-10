# frozen_string_literal: true

module Users
  class Operator < User
    include Teamable

    belongs_to :operator, foreign_key: :operator_id,
                          class_name: '::Operator'

    before_create :set_api_token

    def custom_dashboard_path
      url_helpers.dashboard_internship_offers_path
    rescue ActionController::UrlGenerationError
      url_helpers.account_path
    end

    def dashboard_name
      'Mes offres'
    end

    def invitation_email = nil

    def operator? = true
    def employer_like? = true

    def presenter
      Presenters::Operator.new(self)
    end

    private

    def set_api_token
      self.api_token = SecureRandom.uuid
    end
  end
end
