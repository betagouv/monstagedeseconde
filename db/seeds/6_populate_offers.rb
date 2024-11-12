def populate_internship_offers
  current_school_year = SchoolYear::Current.new.beginning_of_period
  weeks = SchoolTrack::Seconde.both_weeks
  weeks += Week.selectable_from_now_until_end_of_school_year
  # public sector
  # 1
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    siret:,
    max_candidates: 5,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_paqte.first,
    is_public: false,
    title: 'Stage assistant.e ressources humaines - Service des recrutements',
    description: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
    employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile.",
    employer_website: 'http://www.dtpm.fr/',
    street: '56 rue d\'Entraigues , Tours',
    zipcode: '37000',
    city: 'Tours',
    coordinates: { latitude: Coordinates.tours[:latitude], longitude: Coordinates.tours[:longitude] },
    employer_name: Group.is_paqte.first.name,
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi",
    internship_weeks_number: 2
  )

  # 2
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    siret:,
    max_candidates: 5,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_paqte.first,
    is_public: false,
    title: 'Stage avec deux segments de date, bugfix',
    description: 'Scanner metrology est une entreprise unique en son genre'.truncate(249),
    employer_description: 'Scanner metrology a été fondée par le laureat Recherche et Company 2016'.truncate(249),
    employer_website: 'https://www.asml.com/en/careers',
    street: '2 Allée de la Garenne',
    zipcode: '78480',
    city: 'Verneuil-sur-Seine',
    coordinates: { latitude: Coordinates.verneuil[:latitude], longitude: Coordinates.verneuil[:longitude] },
    employer_name: Group.is_paqte.first.name,
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi",
    internship_weeks_number: 2
  )

  # 3
  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 5,
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    siret:,
    period: [0, 1, 2].sample,
    sector: Sector.second,
    group: Group.is_public.last,
    is_public: true,
    title: 'Observation du métier de chef de service - Ministère',
    description: 'Découvrez les réunions et comment se prennent les décisions au plus haut niveau mais aussi tous les interlocuteurs de notre société qui intéragissent avec nos services ',
    employer_description: 'De multiples méthodes de travail et de prises de décisions seront observées',
    street: '18 rue Damiens',
    zipcode: '75012',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: Group.is_public.last.name,
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )

  # 4
  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 6,
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    siret:,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Stage assistant.e banque et assurance',
    description: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
    employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Du temps pour moi',
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )
  # dépubliée
  # 5
  period = [0, 1, 2].sample
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    siret:,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: '(non publiée) Stage assistant.e banque et assurance',
    description: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
    employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Du temps pour moi',
    max_candidates: 7,
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )

  # 6
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    siret:,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Stage editeur - A la recherche du temps passé par les collaborateurs',
    description: 'Vous assistez la responsable de secteur dans la gestion des projets internes touchant à la gestion des contrats.',
    employer_description: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    street: '129 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'Editegis',
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    internship_weeks_number: 2,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )
  # 7
  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 7,
    school_year: 2023,
    employer: Users::Employer.first,
    contact_phone: '+33637607757',
    siret:,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Observation du métier d\'enseignant de mathématique - Lycée Jean Moulin',
    description: 'Vous assistez au cours de mathématiques de 2de générale du lycée Jean Moulin',
    employer_description: 'Le métier de professeur de mathématiques consiste à enseigner les mathématiques aux élèves de lycée. Il peut également enseigner dans le supérieur. Il peut être amené à participer à des projets pédagogiques et à encadrer des élèves.',
    street: '56 rue d\'Entraigues , Tours',
    zipcode: '37000',
    city: 'Tours',
    coordinates: { latitude: Coordinates.tours[:latitude], longitude: Coordinates.tours[:longitude] },
    employer_name: 'Education Nationale',
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    internship_weeks_number: 2,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )

  area_id = Users::Operator.first.reload.internship_offer_areas.first.id
  # 8 api - 1
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    contact_phone: '+33637607756',
    siret:,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: "API - Observation du métier d'Administrateur de systèmes informatiques - IBM SERVICES CENTER",
    description: "Venez découvrir le métier d'administrateur systèmes ! Vous observerez comment nos administrateurs garantissent aux clients le bon fonctionnement etc.",
    employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: FFaker::Guid.guid,
    permalink: 'https://www.google.fr',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'IBM',
    internship_offer_area_id: area_id,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )

  # 9 api - 2
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    contact_phone: '+33637607756',
    siret:,
    period: [0, 1, 2].sample,
    school_year: 2023,
    sector: Sector.first,
    group: Group.is_public.first,
    is_public: false,
    title: "Découverte des métiers administratifs de l'Education nationale",
    description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents  ...",
    employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef magasinier',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: FFaker::Guid.guid,
    permalink: 'https://www.google.fr',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Ministère de l\'Education Nationale',
    internship_offer_area_id: area_id,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )

  # 10
  description = ' - Présentation des services de la direction régionale de Valenciennes (service contentieux, pôle action économique). - Présentation de la recette interrégionale (service de perception). - Immersion au sein d’un bureau de douane (gestion des procédures, déclarations en douane, dédouanement, contrôles des déclarations et des marchandises).'
  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 5,
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte des services douaniers de Valenciennes',
    description: description,
    employer_description: 'La douane assure des missions fiscales et de lutte contre les trafics illicites et la criminalité organisée.',
    employer_website: 'http://www.prefectures-regions.gouv.fr/hauts-de-france/Region-et-institutions/Organisation-administrative-de-la-region/Les-services-de-l-Etat-en-region/Direction-interregionale-des-douanes/Direction-interregionale-des-douanes',
    street: '2 rue jean moulin',
    zipcode: '95160',
    city: 'Montmorency',
    coordinates: { latitude: Coordinates.montmorency[:latitude], longitude: Coordinates.montmorency[:longitude] },
    employer_name: 'Douanes Assistance Corp.',
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi",
    internship_weeks_number: 2
  )

  # 11
  description = " - Présentation des services de la succursale MetaBoutShop - Présentation des principes fondamentaux du métier. - Immersion au sein d’une équipe de gestionnaire de la boutique. Proposition de gestion de portefeuille de boutiques et de stands fictifs en fin de stage, avec les conseils du tuteur'."
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    max_candidates: 5,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte du travail de gestionnaire en ligne',
    description: description,
    employer_description: 'Le métier de gestionnaire consiste à optimiser les ressources de la MetaBoutShop en spéculant sur des valeurs mobilières',
    street: '2 Allée de la Garenne',
    zipcode: '78480',
    city: 'Verneuil-sur-Seine',
    coordinates: { latitude: Coordinates.verneuil[:latitude], longitude: Coordinates.verneuil[:longitude] },
    employer_name: 'MetaBoutShop',
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi",
    internship_weeks_number: 2
  )

  InternshipOffers::WeeklyFramed.all.each { |o| o.publish! if o.may_publish? }

  InternshipOffers::WeeklyFramed.all
                                .to_a
                                .select { |io| io.may_need_update? }
                                &.first
                                &.need_update!
  InternshipOffers::WeeklyFramed.all
                                .to_a
                                .select { |io| io.may_unpublish? }
                                &.last
                                &.unpublish!

  # 11 multi-line
  description = " - Présentation des services de la direction régionale de la banque Acme Corp. (banque de dépôt). - Présentation des principes secondaires du métier. - Immersion au sein d’une équipe d'admiistrateurs de comptes de la banque. Proposition de gestion de portefeuille de clients en fin de stage, avec les conseils du tuteur'. "

  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 5,
    employer: Users::Employer.first,
    contact_phone: '+33637607756',
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    school_year: 2023,
    title: 'Découverte du travail de trader',
    description: description,
    employer_description: 'Le métier de trader consiste à optimiser les ressources de la banque Oyonnax Corp. en spéculant sur des valeurs mobilières',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef de service',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'Oyonnax Corp.',
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: weeks,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi",
    internship_weeks_number: 2
  )

  # 12
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    contact_phone: '+33627607756',
    siret:,
    max_candidates: 2,
    period: [0, 1, 2].sample,
    sector: Sector.fourth,
    group: Group.is_paqte.second,
    is_public: false,
    title: 'Stage concessionnaire automobile',
    description: "Vous assistez la responsable de la concession automobile, aux ventes de véhicules, et observez les manipulations nécessaires pour la logistique et l'approvisionnement des véhicules.",
    employer_description: 'Un concessionnaire offre un service de qualité et, pour ses clients, la fierté de posséder un véhicule de qualité.',
    employer_website: 'http://www.dtpm.fr/',
    street: '30 rue Jean Soula',
    zipcode: '33000',
    city: 'Bordeaux',
    coordinates: { latitude: Coordinates.bordeaux[:latitude], longitude: Coordinates.bordeaux[:longitude] },
    employer_name: Group.is_paqte.second.name,
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    grades: Grade.all,
    lunch_break: "L'élève doit prévoir son repas de midi"
  )
  InternshipOffer.last.publish!

  # 13
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    contact_phone: '+33637607156',
    siret: '88339868700011',
    max_candidates: 1,
    period: [0, 1, 2].sample,
    sector: Sector.second,
    group: nil,
    is_public: false,
    title: 'Stage cordonnerie',
    description: "Vous observez le métier et la gestion de la clientèle d'une cordonnnerie.",
    employer_description: 'Un artisan fier de son métier.',
    employer_website: nil,
    street: '12, rue de la Serpe',
    zipcode: '37000',
    city: 'Tours',
    coordinates: { latitude: Coordinates.tours[:latitude], longitude: Coordinates.tours[:longitude] },
    employer_name: Group.is_paqte.second.name,
    internship_offer_area_id: Users::Employer.first.internship_offer_areas.first.id,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    lunch_break: "L'élève doit prévoir son repas de midi",
    grades: Grade.all
  )
  InternshipOffer.last.publish!

  # 14
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    contact_phone: '+33637607756',
    siret:,
    period: [0, 1, 2].sample,
    sector: Sector.first,
    group: Group.is_public.first,
    is_public: false,
    title: "Découverte des métiers administratifs de l'Education nationale",
    description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents  ...",
    employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: FFaker::Guid.guid,
    permalink: 'https://www.google.fr',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Ministère de l\'Education Nationale',
    internship_offer_area_id: area_id,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    lunch_break: "L'élève doit prévoir son repas de midi",
    grades: Grade.all
  )
  InternshipOffer.last.publish!

  # 15 older school year
  current_year = SchoolTrack::Seconde.current_year
  former_year = current_year - 1
  weeks = SchoolTrack::Seconde.both_weeks(year: former_year)
  weeks += Week.of_previous_school_year
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    contact_phone: '+33637607756',
    siret:,
    sector: Sector.first,
    group: Group.is_public.first,
    is_public: false,
    title: "2023 : Découverte des métiers administratifs de l'Education nationale",
    description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents  ...",
    employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'Paris',
    remote_id: FFaker::Guid.guid,
    permalink: 'https://www.google.fr',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Ministère de l\'Education Nationale',
    internship_offer_area_id: area_id,
    school_year: 2023,
    period: 1,
    weeks: Week.selectable_from_now_until_end_of_school_year,
    lunch_break: "L'élève doit prévoir son repas de midi",
    grades: Grade.all
  )
  InternshipOffer.last.publish!
end

call_method_with_metrics_tracking([:populate_internship_offers])
