module Services::Omogen
  class SygneResponsible
    attr_accessor :last_name, :first_name, :email, :phone, :address, :level, :civility

    #   [
    #     {:name=>"BADEZ",
    #   :first_name=>"Claudette",
    #   :email=>"O*************@email.co",
    #   :phone=>"04XXXXXXXX",
    #   :address=>"4, rue du Muguet, Le Banel 12110 AUBIN",
    #   :level=>"3",
    #   :sexe=>"F"},
    #  {:name=>"CHIERICI",
    #   :first_name=>"Frederic",
    #   :email=>"I*************@email.co",
    #   :phone=>"04XXXXXXXX",
    #   :address=>"4, rue du Muguet, Le Banel 12110 AUBIN",
    #   :level=>"1",
    #   :sexe=>"F"},
    #  {:name=>"GROHIN",
    #   :first_name=>"Juliette",
    #   :email=>"G*************@email.co",
    #   :phone=>"04XXXXXXXX",
    #   :address=>"4, rue du Muguet, Le Banel 12110 AUBIN",
    #   :level=>"1",
    #   :sexe=>"M"}
    #   ]

    private

    def initialize(hash)
      @last_name = hash[:nomFamille]
      @first_name = hash[:prenom]
      @email = hash[:email]
      @phone = hash[:telephonePersonnel]
      @address = format_address(hash[:adrResidenceResp])
      @level = hash[:codeNiveauResponsabilite]
      @civility = hash[:codeCivilite] == '1' ? 'M.' : 'Mme'
    end

    def format_address(address_hash)
      "#{address_hash[:adresseLigne1]}, #{address_hash[:adresseLigne2]} #{address_hash[:codePostal]} #{address_hash[:libelleCommune]}"
    end
  end
end
