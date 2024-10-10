# frozen_string_literal: true

module Users
  class Statistician < User
    include Signatorable
    include Teamable
    has_many :internship_offers, as: :employer,
                                 dependent: :destroy

    has_many :kept_internship_offers, -> { merge(InternshipOffer.kept) },
             class_name: 'InternshipOffer', foreign_key: 'employer_id'

    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications
    has_many :organisations
    has_many :tutors
    has_many :internship_offer_infos

    belongs_to :academy_region, optional: true, class_name: 'AcademyRegion', foreign_key: 'academy_region_id'

    before_update :trigger_agreements_creation
    # before_validation :confirm
    # Beware : order matters here !
    after_create :notify_manager
    after_update :confirm_if_validated

    # Validations
    validates_inclusion_of :accept_terms, in: ['1', true],
                                          message: :accept_terms,
                                          on: :create

    scope :active, -> { where(discarded_at: nil) }

    def custom_dashboard_path
      url_helpers.reporting_dashboards_path(
        department: department_name,
        school_year: SchoolYear::Current.new.beginning_of_period.year
      )
    end

    def custom_candidatures_path(parameters = {})
      url_helpers.dashboard_candidatures_path(parameters)
    end

    def custom_dashboard_paths
      [
        url_helpers.reporting_internship_offers_path,
        url_helpers.reporting_schools_path,
        custom_dashboard_path
      ]
    end

    def statistician? = true
    def employer_like? = true

    def confirm_if_validated
      return unless statistician_validation && confirmed_at.nil?

      self.confirmed_at = Time.now if confirmed_at.nil?
      save
      SendStatisticianValidatedEmailJob.perform_later(self)
    end

    def notify_manager
      SendNewStatisticianEmailJob.perform_later(self)
    end

    def role
      self.class.name.demodulize.underscore
    end

    def signatory_role
      Signature.signatory_roles[:employer]
    end

    def trigger_agreements_creation
      return unless changes[:agreement_signatorable] == [false, true]

      AgreementsAPosterioriJob.perform_later(user_id: id)
    end
  end
end
