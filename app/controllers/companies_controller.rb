class CompaniesController < ApplicationController
  layout 'search'

  def index
    @companies = [
      OpenStruct.new(
        name: 'Oracle',
        job: 'Conseiller offres internet',
        sector: 'Télécommunication sans fil',
        size: '+500 salariés',
        address: ' 25 rue de la gare, 75001 Paris',
        link: 'https://www.oracle.com/fr/index.html'
      ),
      OpenStruct.new(
        name: 'Google',
        job: 'Développeur web',
        sector: 'Technologie de l\'information',
        size: '+500 salariés',
        address: '8 rue de Londres, 75009 Paris',
        link: 'https://www.google.com/'
      ),
       OpenStruct.new(
        name: 'Microsoft',
        job: 'Ingénieur informatique',
        sector: 'Technologie de l\'information',
        size: '+500 salariés',
        address: '39 quai du Président Roosevelt, 92130 Issy-les-Moulineaux',
        link: 'https://www.microsoft.com/fr-fr'
      ),
       OpenStruct.new(
        name: 'Apple',
        job: 'Développeur mobile',
        sector: 'Technologie de l\'information',
        size: '+500 salariés',
        address: '7 place d\'Iéna, 75016 Paris',
        link: 'https://www.apple.com/fr/'
      ),
       OpenStruct.new(
        name: 'Facebook',
        job: 'Community manager',
        sector: 'Technologie de l\'information',
        size: '+500 salariés',
        address: '6 rue Ménars, 75002 Paris',
        link: 'https://fr-fr.facebook.com/'
      ),
       OpenStruct.new(
        name: 'Amazon',
        job: 'Développeur web',
        sector: 'Technologie de l\'information',
        size: '+500 salariés',
        address: '67 boulevard du Général Leclerc, 92110 Clichy',
        link: 'https://www.amazon.fr/'
      ),
       OpenStruct.new(
        name: 'IBM',
        job: 'Ingénieur informatique',
        sector: 'Technologie de l\'information',
        size: '+500 salariés',
        address: '17 avenue de l\'Europe, 92275 Bois-Colombes',
        link: 'https://www.ibm.com/fr-fr'
      ),
       OpenStruct.new(
        name: 'Twitter',
        job: 'Community manager',
        sector: 'Technologie de l\'information',
        size: '+500 salariés',
        address: '78 rue Taitbout, 75009 Paris',
        link: 'https://twitter.com/?lang=fr'
       )
    ]
    @pages = InternshipOffer.all.order(created_at: :desc).page(params[:page]).per(3)
  end
end