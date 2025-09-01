class TempRebuild
  def self.first_employer_area_id = Users::Employer.first.current_area_id
  def self.first_operator_employer_area_id = Users::Operator.first.current_area_id
  def self.current_school_year = SchoolYear::Current.new.offers_beginning_of_period
  def self.seconde_weeks = SchoolTrack::Seconde.both_weeks
  def self.troisieme_weeks = Week.troisieme_weeks.to_a
  def self.all_weeks = seconde_weeks + troisieme_weeks

  def self.education_sector = Sector.find_by(uuid: 's22')
  def self.it_sector = Sector.find_by(uuid: 's31')
  def self.care_sector = Sector.find_by(uuid: 's26')

  def self.create_api_offers
    data_array = [{
      employer: Users::Operator.first,
      contact_phone: '+33637607756',
      siret: '55211846503644',
      period: 0,
      sector: it_sector,
      is_public: false,
      title: "API - 2de - Observation du métier d'Administrateur de systèmes informatiques - IBM SERVICES CENTER",
      description: "Venez découvrir le métier d'administrateur systèmes ! Vous observerez comment nos administrateurs garantissent aux clients le bon fonctionnement etc.",
      employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
      street: '128 rue brancion',
      zipcode: '75015',
      city: 'paris',
      remote_id: '2B6FFEB1-3FF3-4947-94A8-84B54A644C8A', # FFaker::UUID.uuidv4
      permalink: 'https://www.google.fr',
      coordinates: { latitude: Coordinates.paris[:latitude],
                     longitude: Coordinates.paris[:longitude] },
      employer_name: 'IBM',
      internship_offer_area_id: first_operator_employer_area_id,
      weeks: seconde_weeks,
      grades: [Grade.seconde],
      entreprise_full_address: '128 rue brancion, 75015 paris',
      lunch_break: "L'élève doit prévoir son repas de midi"
    }, {
      employer: Users::Operator.first,
      contact_phone: '+33637607756',
      siret: '17070431600018',
      period: 1,
      sector: education_sector,
      is_public: false,
      title: "API - (2et3) Découverte des métiers administratifs de l'Education nationale",
      description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents  ...",
      employer_description: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
      tutor_name: 'Martin Fourcade',
      tutor_email: 'fourcade.m@gmail.com',
      tutor_phone: '+33637607756',
      tutor_role: 'Chef magasinier',
      street: '128 rue brancion',
      zipcode: '75015',
      city: 'paris',
      remote_id: 'fbf77c1e-97d8-4099-b141-d0c73faae501',
      permalink: 'https://www.google.fr',
      coordinates: { latitude: 44.734695707874565, longitude: 4.5991470717793606 },
      employer_name: 'Ministère de l\'Education Nationale',
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
      city: 'paris',
      remote_id: '44824cae-4551-49af-a2cb-8f7d3f3b1c26',
      permalink: 'https://www.google.fr',
      coordinates: { latitude: 48.856024566102214, longitude: 2.322552930884083 },
      employer_name: 'Ministère de l\'Education Nationale',
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

  def self.create_offers
    data_array = [{
      employer: Users::Employer.fourth,
      contact_phone: '+33637607756',
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
    data_array.each do |data|
      offer = InternshipOffers::WeeklyFramed.new(data)

      # message_box.broadcast_info(message_content: offer.errors.full_messages, time_value: 0)
      raise StandardError, offer.errors.full_messages unless offer.valid?

      offer.save!
    end
  end
end
