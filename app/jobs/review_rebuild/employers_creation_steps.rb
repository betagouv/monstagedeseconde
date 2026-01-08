module ReviewRebuild
  module EmployersCreationSteps # and Users::Operators
    extend ActiveSupport::Concern

    def create_employers
      data_array = [
        { email: 'theophile.gauthier@flora-international.com',
          first_name: 'Théophile',
          last_name: 'Gauthier',
          employer_role: 'ceo',
          phone: '+330612345676' },
        { email: 'julien.potier@food-culture.com',
          first_name: 'Julien',
          last_name: 'Potier',
          employer_role: 'ressources humaines',
          phone: '+330612345677' },
        { email: 'amina.moussa@capricorne-acme.com',
          employer_role: 'chef de service',
          first_name: 'Amina',
          last_name: 'Moussa',
          phone: '+330622345678' },
        { email: 'virginie.chottin@du-temps-pour-moi.com',
          employer_role: "directrice d'agence",
          first_name: 'Virginie',
          last_name: 'Chottin',
          phone: '+330622345679' }
      ]
      data_array.each do |data|
        create_employers_from_hash(data)
      end
    end

    def create_users_operators
      Operator.find_or_create_by!(name: 'Asso Operator', target_count: 100)
      Operator.find_or_create_by!(name: 'Croix Rouge', target_count: 100)
      Operator.find_or_create_by!(name: 'Ambitius Companies', target_count: 100)
      data_array = [
        { email: 'jean.valjean@asso-operator.fr',
          first_name: 'Jean',
          last_name: 'Valjean',
          phone: '+330612345976',
          operator_id: Operator.first.id },
        { email: 'julien.sorel@croix-rouge.fr',
          first_name: 'Julien',
          last_name: 'Sorel',
          phone: '+330612345977',
          operator_id: Operator.second.id },
        { email: 'eugene.de-rastignac@ambition-companies.com',
          first_name: 'Eugène',
          last_name: 'de Rastignac',
          phone: '+330612345978',
          operator_id: Operator.third.id }
      ]
      data_array.each do |data|
        create_users_operators_from_hash(data)
      end
    end

    def create_employers_from_hash(data)
      data = add_mandatory_attributes(data)
      Users::Employer.create!(**data)
    end

    def create_users_operators_from_hash(data)
      data = add_mandatory_attributes(data)
      Users::Operator.create!(**data)
    end

    def create_extra_areas
      # none actually, upon MOA request
    end
  end
end
