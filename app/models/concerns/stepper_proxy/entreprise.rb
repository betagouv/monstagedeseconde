module StepperProxy
  module Entreprise
    extend ActiveSupport::Concern

    included do
      belongs_to :group, optional: true
      belongs_to :internship_occupation
      belongs_to :sector

      before_validation :clean_siret
      before_save :entreprise_used_name

      attr_accessor :entreprise_chosen_full_address,
                    :entreprise_coordinates_longitude,
                    :entreprise_coordinates_latitude

      def clean_siret
        self.siret = siret.gsub(' ', '') if try(:siret)
      end

      def entreprise_used_name
        self.employer_name = employer_chosen_name.presence || employer_name
      end
    end
  end
end
