# frozen_string_literal: true

module Presenters
  module SiretFormattable
    def formal_siret
      return 'N/A' unless siret.present?

      siret.gsub(/(\d{3})(\d{3})(\d{3})(\d{5})/, '\1 \2 \3 \4')
    end
  end
end
