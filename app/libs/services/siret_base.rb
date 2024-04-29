module Services
  class SiretBase

    def store
      return unless siret

      siret_base = SiretBase.find_by(siret: siret)
      if siret_base && internship_offer.last_date > siret_base.last_activity
        siret_base.update(last_activity: internship_offer.last_date)
      elsif siret_base.nil?
        SiretBase.create(siret: siret, last_activity: internship_offer.last_date)
      end
    end


    attr_reader :internship_offer, :siret

    private

    def initialize(internship_offer)
      @internship_offer = internship_offer
      @siret = internship_offer.siret
    end
  end
end