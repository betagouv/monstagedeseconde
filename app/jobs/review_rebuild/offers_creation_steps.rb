module ReviewRebuild
  module OffersCreationSteps
    extend ActiveSupport::Concern

    def first_employer_area_id = Users::Employer.first.current_area_id
    def second_employer_area_id = Users::Employer.second.current_area_id
    def third_employer_area_id = Users::Employer.third.current_area_id
    def fourth_employer_area_id = Users::Employer.fourth.current_area_id

    def first_operator_employer_area_id = Users::Operator.first.current_area_id
    def current_school_year = SchoolYear::Current.new.offers_beginning_of_period
    def seconde_weeks = SchoolTrack::Seconde.both_weeks
    def troisieme_weeks = Week.troisieme_weeks.to_a
    def all_weeks = seconde_weeks + troisieme_weeks

    def education_sector = Sector.find_by(uuid: 's22')
    def it_sector = Sector.find_by(uuid: 's31')
    def care_sector = Sector.find_by(uuid: 's26')
    def industry_sector = Sector.find_by(uuid: 's30')
    def service_sector = Sector.find_by(uuid: 's12')

    def first_employer_name = 'Le marais fleuri - artisan Fleuriste'
    def second_employer_name = "Ministère de l'Education Nationale"
    def third_employer_name = "Bureau d'études CAPRICORNE"
    def fourth_employer_name = 'Du temps pour moi'

    def first_employer = Users::Employer.first
    def second_employer = Users::Employer.second
    def third_employer = Users::Employer.third
    def fourth_employer = Users::Employer.fourth

    def create_api_offers
      data_array = [{
        employer: Users::Operator.first,
        contact_phone: '+33637607754',
        siret: '55211846503644',
        period: 0,
        sector: it_sector,
        is_public: false,
        title: "API - 2de - Observation du métier d'Administrateur de systèmes informatiques - IBM SERVICES CENTER",
        description: "Venez découvrir le métier d'administrateur systèmes ! Vous observerez comment nos administrateurs garantissent aux clients le bon fonctionnement etc.",
        employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
        street: '128 rue brancion',
        zipcode: '75015',
        city: 'Paris',
        remote_id: '2B6FFEB1-3FF3-4947-94A8-84B54A644C8A', # FFaker::UUID.uuidv4
        permalink: 'https://www.google.fr',
        coordinates: { latitude: Coordinates.paris[:latitude],
                       longitude: Coordinates.paris[:longitude] },
        employer_name: 'IBM',
        internship_offer_area_id: first_operator_employer_area_id,
        weeks: seconde_weeks,
        grades: [Grade.seconde],
        entreprise_full_address: '128 rue brancion, 75015 Paris',
        lunch_break: "L'élève doit prévoir son repas de midi"
      }, {
        employer: Users::Operator.first,
        contact_phone: '+33637607755',
        siret: '17070431600018',
        period: 1,
        sector: education_sector,
        is_public: false,
        title: "API - (2et3) Découverte des métiers administratifs de l'Education nationale",
        description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents  ...",
        employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
        street: '128 rue brancion',
        zipcode: '75015',
        city: 'Paris',
        remote_id: 'fbf77c1e-97d8-4099-b141-d0c73faae501',
        permalink: 'https://www.google.fr',
        coordinates: { latitude: 44.734695707874565, longitude: 4.5991470717793606 },
        employer_name: second_employer_name,
        internship_offer_area_id: first_operator_employer_area_id,
        weeks: all_weeks,
        grades: Grade.all,
        entreprise_full_address: 'PLACE ANDRE MALRAUX, 07000 PRIVAS',
        lunch_break: "L'élève doit prévoir son repas de midi"
      }, {
        employer: Users::Operator.second,
        contact_phone: '+33637607756',
        siret: '17070431600018',
        period: 2,
        sector: education_sector,
        is_public: false,
        title: "API - (3e) Découverte des métiers administratifs de l'Education nationale",
        description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents  ...",
        employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
        street: '104, rue de Grenelle',
        zipcode: '75007',
        city: 'Paris',
        remote_id: '44824cae-4551-49af-a2cb-8f7d3f3b1c26',
        permalink: 'https://www.google.fr',
        coordinates: { latitude: 48.856024566102214, longitude: 2.322552930884083 },
        employer_name: second_employer_name,
        internship_offer_area_id: first_operator_employer_area_id,
        weeks: troisieme_weeks,
        lunch_break: "L'élève doit prévoir son repas de midi",
        grades: [Grade.troisieme]
      }]
      data_array.each do |data|
        offer = InternshipOffers::Api.new(data)
        raise StandardError, offer.errors.full_messages.to_sentence unless offer.valid?

        offer.save!
      end
    end

    def create_offers
      data_array = [{ # 1 Tours - 2,3
        employer: fourth_employer,
        contact_phone: '+33639607756',
        siret: '50178161100022',
        max_candidates: 5,
        period: 0,
        sector: care_sector,
        is_public: false,
        title: '(2et3) Stage assistant.e ressources humaines - Service des recrutements',
        description: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
        employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile.",
        employer_website: 'http://www.dtpm.fr/',
        street: '56 rue d\'Entraigues , Tours',
        zipcode: '37000',
        city: 'Tours',
        coordinates: { latitude: Coordinates.tours[:latitude], longitude: Coordinates.tours[:longitude] },
        employer_name: 'Du temps pour moi',
        internship_offer_area_id: first_employer_area_id,
        weeks: all_weeks,
        grades: Grade.all,
        entreprise_full_address: '56 rue d\'Entraigues , Tours',
        lunch_break: "L'élève doit prévoir son repas de midi"
      }]
      data_array << ({ # 2 Paris - 2,3
        employer: first_employer,
        contact_phone: '+33637607456',
        max_candidates: 5,
        period: 1,
        sector: industry_sector,
        is_public: false,
        title: '(2et3) Stage de métrologie - scanner',
        description: 'Scanner metrology est une entreprise unique en son genre'.truncate(249),
        employer_description: 'Scanner metrology a été fondée par le laureat Recherche et Company 2016'.truncate(249),
        employer_website: 'https://www.asml.com/en/careers',
        street: '2 Allée de la Garenne',
        zipcode: '78480',
        city: 'Verneuil-sur-Seine',
        coordinates: { latitude: Coordinates.verneuil[:latitude],
                       longitude: Coordinates.verneuil[:longitude] },
        employer_name: first_employer_name,
        internship_offer_area_id: first_employer_area_id,
        weeks: all_weeks,
        grades: Grade.all,
        entreprise_full_address: '2 Allée de la Garenne, 78480 Verneuil-sur-Seine',
        lunch_break: "L'élève doit prévoir son repas de midi"
      })
      data_array << ({ # 3 Paris - 2,3
        max_candidates: 45,
        employer: first_employer,
        contact_phone: '+33637607456',
        period: 2,
        sector: education_sector,
        group: Group.is_public.last,
        is_public: true,
        title: '(2et3) Observation du métier de chef de service - Ministère',
        description: 'Découvrez les réunions et comment se prennent les décisions au plus haut niveau mais aussi tous les interlocuteurs de notre société qui intéragissent avec nos services ',
        employer_description: 'De multiples méthodes de travail et de prises de décisions seront observées',
        street: '18 rue Damiens',
        zipcode: '75012',
        city: 'Paris',
        coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
        employer_name: first_employer_name,
        internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
        weeks: all_weeks.last(10),
        grades: Grade.all,
        entreprise_full_address: '18 rue Damiens, 75012 Paris',
        lunch_break: "L'élève doit prévoir son repas de midi"
      })
      data_array << ({ # 4 Paris - 3
        max_candidates: 6,
        employer: fourth_employer,
        contact_phone: '+33639607756',
        period: 1,
        sector: care_sector,
        is_public: false,
        title: '(3e) Stage assistant.e banque et assurance',
        description: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
        employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
        employer_website: 'http://www.dtpm.fr/',
        street: '128 rue brancion',
        zipcode: '75015',
        city: 'Paris',
        coordinates: { latitude: 48.82914668864281, longitude: 2.301552087890998 },
        employer_name: 'Du temps pour moi',
        internship_offer_area_id: fourth_employer_area_id,
        weeks: troisieme_weeks,
        grades: [Grade.troisieme],
        entreprise_full_address: '128 rue brancion, 75015 Paris',
        lunch_break: "L'élève doit prévoir son repas de midi"
      })
      data_array << ({ # 5 Paris unpublished
        employer: fourth_employer,
        contact_phone: '+33639607756',
        period: 0,
        sector: Sector.first,
        is_public: false,
        title: '(2de) (non publiée) Stage assistant.e banque et assurance',
        description: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
        employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
        employer_website: 'http://www.dtpm.fr/',
        street: '128 rue brancion',
        zipcode: '75015',
        city: 'Paris',
        coordinates: { latitude: 48.866667, longitude: 2.333333 },
        employer_name: 'Du temps pour moi',
        max_candidates: 7,
        internship_offer_area_id: fourth_employer_area_id,
        weeks: seconde_weeks,
        grades: [Grade.seconde],
        entreprise_full_address: '128 rue brancion, 75015 Paris',
        lunch_break: "L'élève doit prévoir son repas de midi",
        published_at: nil
      })
      data_array << ({ # 6 Tours, 2
        employer: fourth_employer,
        contact_phone: '+33639607756',
        period: 0,
        sector: Sector.first,
        is_public: false,
        title: '(2de) Stage editeur - A la recherche du temps passé par les collaborateurs',
        description: 'Vous assistez la responsable de secteur dans la gestion des projets internes touchant à la gestion des contrats.',
        employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
        employer_website: 'http://www.dtpm.fr/',
        street: '129 rue brancion',
        zipcode: '75015',
        city: 'Paris',
        coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
        employer_name: 'Editegis',
        internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
        weeks: seconde_weeks,
        grades: [Grade.seconde],
        entreprise_full_address: '129 rue brancion, 75015 Paris',
        lunch_break: "L'élève doit prévoir son repas de midi"
      })
      data_array << ({ # 7 Tours, 3
        max_candidates: 7,
        employer: second_employer,
        contact_phone: '+33637607757',
        period: 2,
        sector: education_sector,
        is_public: true,
        title: '(3e) Observation du métier d\'enseignant de mathématique - Lycée Jean Moulin',
        description: 'Vous assistez au cours de mathématiques de 2de générale du lycée Jean Moulin',
        employer_description: 'Le métier de professeur de mathématiques consiste à enseigner les mathématiques aux élèves de lycée. Il peut également enseigner dans le supérieur. Il peut être amené à participer à des projets pédagogiques et à encadrer des élèves.',
        street: '56 rue d\'Entraigues , Tours',
        zipcode: '37000',
        city: 'Tours',
        coordinates: { latitude: Coordinates.tours[:latitude], longitude: Coordinates.tours[:longitude] },
        employer_name: 'Education Nationale',
        internship_offer_area_id: second_employer_area_id,
        weeks: troisieme_weeks,
        grades: [Grade.troisieme],
        entreprise_full_address: '156 rue d\'Entraigues , 37000 Tours',
        lunch_break: "L'élève doit prévoir son repas de midi"
      })
      description = ' - Présentation des services de la direction régionale de Valenciennes (service contentieux, pôle action économique). - Présentation de la recette interrégionale (service de perception). - Immersion au sein d’un bureau de douane (gestion des procédures, déclarations en douane, dédouanement, contrôles des déclarations et des marchandises).'
      data_array << ({ # 8 Montmorency - 2,3
        max_candidates: 5,
        employer: third_employer,
        contact_phone: '+33637607461',
        period: 0,
        sector: industry_sector,
        is_public: false,
        title: '(2et3) Découverte des services douaniers de Valenciennes',
        description: description,
        employer_description: 'La douane assure des missions fiscales et de lutte contre les trafics illicites et la criminalité organisée.',
        employer_website: 'http://www.prefectures-regions.gouv.fr/hauts-de-france/Region-et-institutions/Organisation-administrative-de-la-region/Les-services-de-l-Etat-en-region/Direction-interregionale-des-douanes/Direction-interregionale-des-douanes',
        street: '2 rue jean moulin',
        zipcode: '95160',
        city: 'Montmorency',
        coordinates: { latitude: Coordinates.montmorency[:latitude], longitude: Coordinates.montmorency[:longitude] },
        employer_name: 'Douanes Assistance Corp.',
        internship_offer_area_id: third_employer_area_id,
        weeks: all_weeks,
        grades: Grade.all,
        entreprise_full_address: '2 rue jean moulin, 95160 Montmorency',
        lunch_break: "L'élève doit prévoir son repas de midi"
      })
      data_array << ({ # 9 Paris - 3
        employer: third_employer,
        contact_phone: '+33639607756',
        period: 0,
        sector: industry_sector,
        is_public: false,
        title: '(2de) (non publiée) Stage direction de projet interne',
        description: 'Le stage proposé consiste à assister les équipes dans la gestion des dossiers clients et la préparation des rendez-vous. Capricorne entend prendre soin de la qualité de l\'accompagnement proposé.',
        employer_description: "Capricorne - Bureaux d'études est un bureau d'études spécialisé dans l'accompagnement des entreprises.",
        employer_website: 'http://www.capricorne-be.fr/',
        street: '111, rue Cardinet',
        zipcode: '75017',
        city: 'Paris',
        coordinates: { latitude: 48.88541057696657, longitude: 2.3112522618969735 },
        employer_name: "Capricorne - Bureaux d'études",
        max_candidates: 7,
        internship_offer_area_id: fourth_employer_area_id,
        weeks: seconde_weeks,
        grades: [Grade.seconde],
        entreprise_full_address: '111 rue Cardinet, 75017 Paris',
        lunch_break: "L'élève doit prévoir son repas de midi",
        published_at: nil
      })
      data_array << ({ # 10 Paris - 2,3
        employer: first_employer,
        contact_phone: '+33639607756',
        period: 0,
        sector: service_sector,
        is_public: false,
        title: '(2de-3e) Stage marketing',
        description: 'Le stage proposé consiste à assister les équipes du magasin dans la construction d\'un plan marketing à même de supplanter tous les autres fleuristes de Paris. Vaincre ou mourir !',
        employer_description: 'Justin fleuriste',
        employer_website: 'http://www.fleuriste-du marais.fr/',
        street: '25 rue Legendre',
        zipcode: '75017',
        city: 'Paris',
        coordinates: { latitude: 48.88409591622411, longitude: 2.314062726519731 },
        employer_name: 'Les fleuristes du marais',
        max_candidates: 17,
        internship_offer_area_id: first_employer_area_id,
        weeks: all_weeks,
        grades: Grade.all,
        entreprise_full_address: '25 rue Legendre, 75017 Paris',
        lunch_break: "L'élève doit prévoir son repas de midi",
        published_at: nil
      })
      description = " Présentation des services de la direction régionale de la banque Acme Corp. (banque de dépôt). - Présentation des principes secondaires du métier. - Immersion au sein d’une équipe d'admiistrateurs de comptes de la banque. Proposition de gestion de portefeuille de clients en fin de stage, avec les conseils du tuteur'. Le métier de trader consiste à optimiser les ressources de la banque Oyonnax Corp. en spéculant sur des valeurs mobilières "

      data_array << ({ # 11 Paris - 3
        max_candidates: 2,
        employer: first_employer,
        contact_phone: '+33637607756',
        sector: service_sector,
        is_public: false,
        school_year: 2025,
        title: '(3e) Découverte du travail de trader',
        description: description,
        street: '12 rue Abel',
        zipcode: '75015',
        city: 'Paris',
        coordinates: { latitude: 48.84702901622884, longitude: 2.375131193980671 },
        employer_name: 'Oyonnax Corp.',
        internship_offer_area_id: first_employer_area_id,
        weeks: troisieme_weeks,
        grades: [Grade.troisieme],
        entreprise_full_address: '12 rue Abel, 75012 paris',
        lunch_break: "L'élève doit prévoir son repas de midi"
      })
      data_array.each do |data|
        data.merge!(weekly_hours: ['08:30', '17:00'])
        offer = InternshipOffers::WeeklyFramed.new(**data)
        raise StandardError, offer.errors.full_messages.to_sentence unless offer.valid?

        offer.save!
      end
      InternshipOffers::WeeklyFramed.fifth.unpublish!
    end

    def tours_offers
      InternshipOffers::WeeklyFramed.where(city: 'Tours')
    end

    def paris_offers
      InternshipOffers::WeeklyFramed.where(city: 'Paris')
    end
  end
end
