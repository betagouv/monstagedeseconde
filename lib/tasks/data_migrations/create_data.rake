require 'pretty_console'
require 'csv'
require 'open-uri'

namespace :data_migrations do
  desc 'create sectors'
  task add_sectors: :environment do
    {
      'Agroéquipement' => 's1',
      'Architecture, urbanisme et paysage' => 's2',
      'Armée - Défense' => 's3',
      'Art et design' => 's4',
      "Artisanat d'art" => 's5',
      'Arts du spectacle' => 's6',
      'Audiovisuel' => 's7',
      'Automobile' => 's8',
      'Banque et assurance' => 's9',
      'Bâtiment et travaux publics (BTP)' => 's10',
      'Bien-être' => 's11',
      'Commerce et distribution' => 's12',
      'Communication' => 's13',
      'Comptabilité, gestion, ressources humaines' => 's14',
      'Conseil et audit' => 's15',
      'Construction aéronautique, ferroviaire et navale' => 's16',
      'Culture et patrimoine' => 's17',
      'Droit et justice' => 's18',
      'Édition, librairie, bibliothèque' => 's19',
      'Électronique' => 's20',
      'Énergie' => 's21',
      'Enseignement' => 's22',
      'Environnement' => 's23',
      'Filiere bois' => 's24',
      'Fonction publique' => 's25',
      'Hôtellerie, restauration' => 's26',
      'Immobilier, transactions immobilières' => 's27',
      'Industrie alimentaire' => 's28',
      'Industrie chimique' => 's29',
      'Industrie, ingénierie industrielle' => 's30',
      'Informatique et réseaux' => 's31',
      'Jeu vidéo' => 's32',
      'Journalisme' => 's33',
      'Logistique et transport' => 's34',
      'Maintenance' => 's35',
      'Marketing, publicité' => 's36',
      'Mécanique' => 's37',
      "Métiers d'art" => 's38',
      'Mode' => 's39',
      'Papiers Cartons' => 's40',
      'Paramédical' => 's41',
      'Recherche' => 's42',
      'Santé' => 's43',
      'Sécurité' => 's44',
      'Services postaux' => 's45',
      'Social' => 's46',
      'Sport' => 's47',
      'Tourisme' => 's48',
      'Traduction, interprétation' => 's49',
      'Verre, béton, céramique' => 's50'
    }.map do |sector_name, sector_uuid|
      next if Sector.find_by(name: sector_name)

      Sector.create!(name: sector_name, uuid: sector_uuid)
      print '.'
    end
  end

  desc 'create academies and regions'
  task populate_academy_regions: :environment do
    [
      'Auvergne-Rhône-Alpes',
      'Bourgogne-Franche-Comté',
      'Bretagne',
      'Centre-Val de Loire',
      'Corse',
      'Grand Est',
      'Guadeloupe',
      'Guyane',
      'Nouvelle-Calédonie',
      'Polynésie française',
      'Hauts-de-France',
      'Ile-de-France',
      'La Réunion',
      'Martinique',
      'Mayotte',
      'Normandie',
      'Nouvelle-Aquitaine',
      'Occitanie',
      'Pays de la Loire',
      "Provence-Alpes-Côte d'Azur"
    ].each do |academy_region_name|
      next if AcademyRegion.find_by(name: academy_region_name)

      AcademyRegion.create!(name: academy_region_name)
      print ' .'
    end
  end

  desc 'create academies'
  task populate_academies: :environment do
    {
      'Auvergne-Rhône-Alpes': [
        { 'Académie de Clermont-Ferrand': 'ac-clermont.fr' },
        { 'Académie de Grenoble': 'ac-grenoble.fr' },
        { 'Académie de Lyon': 'ac-lyon.fr' }
      ],
      'Bourgogne-Franche-Comté': [
        { 'Académie de Besançon': 'ac-besancon.fr' },
        { 'Académie de Dijon': 'ac-dijon.fr' }
      ],
      'Bretagne': [
        { 'Académie de Rennes': 'ac-rennes.fr' }
      ],
      'Centre-Val de Loire': [
        { "Académie d'OrléansTours": 'ac-orleans-tours.fr' }
      ],
      'Corse': [
        { 'Académie de Corse': 'ac-corse.fr' }
      ],
      'Grand Est': [
        { 'Académie de Nancy-Metz': 'ac-nancy-metz.fr' },
        { 'Académie de Reims': 'ac-reims.fr' },
        { 'Académie de Strasbourg': 'ac-strasbourg.fr' }
      ],
      'Guadeloupe': [
        { 'Académie de la Guadeloupe': 'ac-guadeloupe.fr' }
      ],
      'Guyane': [
        { 'Académie de la Guyane': 'ac-guyane.fr' }
      ],
      'Nouvelle-Calédonie': [
        { 'Académie de la Nouvelle-Calédonie': 'ac-noumea.nc' }
      ],
      'Polynésie française': [
        { 'Académie de la Polynésie française': 'ac-polynesie.pf' }
      ],
      'Hauts-de-France': [
        { "Académie d'Amiens": 'ac-amiens.fr' },
        { 'Académie de Lille': 'ac-lille.fr' }
      ],
      'Ile-de-France': [
        { 'Académie de Créteil': 'ac-creteil.fr' },
        { 'Académie de Paris': 'ac-paris.fr' },
        { 'Académie de Versailles': 'ac-versailles.fr' }
      ],
      'La Réunion': [
        { 'Académie de La Réunion': 'ac-reunion.fr' }
      ],
      'Martinique': [
        { 'Académie de Martinique': 'ac-martinique.fr' }
      ],
      'Mayotte': [
        { 'Académie de Mayotte': 'ac-mayotte.fr' }
      ],
      'Normandie': [
        { 'Académie de Normandie': 'ac-normandie.fr' }
      ],
      'Nouvelle-Aquitaine': [
        { 'Académie de Bordeaux': 'ac-bordeaux.fr' },
        { 'Académie de Limoges': 'ac-limoges.fr' },
        { 'Académie de Poitiers': 'ac-poitiers.fr' }
      ],
      'Occitanie': [
        { 'Académie de Montpellier': 'ac-montpellier.fr' },
        { 'Académie de Toulouse': 'ac-toulouse.fr' }
      ],
      'Pays de la Loire': [
        { 'Académie de Nantes': 'ac-nantes.fr' }
      ],
      "Provence-Alpes-Côte d'Azur": [
        { "Académie d'Aix-Marseille": 'ac-aix-marseille.fr' },
        { 'Académie de Nice': 'ac-nice.fr' }
      ]
    }.each do |academy_region_name, academies|
      academy_region = AcademyRegion.find_by(name: academy_region_name)

      academies.each do |academy_hash|
        academy_hash.each do |academy_name, email_domain|
          next if Academy.find_by(name: academy_name)

          Academy.create!(name: academy_name, academy_region:, email_domain:)
          print ' .'
        end
      end
    end
  end

  desc 'update departments with academies'
  task update_departments_with_academies: :environment do
    {
      "Académie de Clermont-Ferrand": [
        { "03": 'Allier' },
        { "15": 'Cantal' },
        { "43": 'Haute-Loire' },
        { "63": 'Puy-de-Dôme' }
      ],
      "Académie de Grenoble": [
        { "07": 'Ardèche' },
        { "26": 'Drôme' },
        { "38": 'Isère' },
        { "74": 'Haute-Savoie' },
        { "73": 'Savoie' }
      ],
      "Académie de Lyon": [
        { "01": 'Ain' },
        { "42": 'Loire' },
        { "69": 'Rhône' }
      ],
      "Académie de Besançon": [
        { "25": 'Doubs' },
        { "39": 'Jura' },
        { "70": 'Haute-Saône' },
        { "90": 'Territoire de Belfort' }
      ],
      "Académie de Dijon": [
        { "21": "Côte-d'Or" },
        { "58": 'Nièvre' },
        { "71": 'Saône-et-Loire' },
        { "89": 'Yonne' }
      ],
      "Académie de Rennes": [
        { "22": "Côtes-d'Armor" },
        { "29": 'Finistère' },
        { "35": 'Ille-et-Vilaine' },
        { "56": 'Morbihan' }
      ],
      "Académie d'OrléansTours": [
        { "18": 'Cher' },
        { "28": 'Eure-et-Loir' },
        { "36": 'Indre' },
        { "37": 'Indre-et-Loire' },
        { "41": 'Loir-et-Cher' },
        { "45": 'Loiret' }
      ],
      "Académie de Corse": [
        { "2A": 'Corse-du-Sud' },
        { "2B": 'Haute-Corse' }
      ],
      "Académie de Nancy-Metz": [
        { "54": 'Meurthe-et-Moselle' },
        { "55": 'Meuse' },
        { "57": 'Moselle' },
        { "88": 'Vosges' }
      ],
      "Académie de Reims": [
        { "08": 'Ardennes' },
        { "10": 'Aube' },
        { "51": 'Marne' },
        { "52": 'Haute-Marne' }
      ],
      "Académie de Strasbourg": [
        { "67": 'Bas-Rhin' },
        { "68": 'Haut-Rhin' }
      ],
      "Académie de la Guadeloupe": [
        { "971": 'Guadeloupe' }
      ],
      "Académie de la Guyane": [
        { "973": 'Guyane' }
      ],
      "Académie de la Nouvelle-Calédonie": [
        { "988": 'Nouvelle-Calédonie' }
      ],
      'Académie de la Polynésie française': [
        { "987": 'Polynésie française' }
      ],
      'Académie de La Réunion': [
        { "974": 'La Réunion' }
      ],
      'Académie de Mayotte': [
        { "976": 'Mayotte' }
      ],
      "Académie d'Amiens": [
        { "02": 'Aisne' },
        { "60": 'Oise' },
        { "80": 'Somme' }
      ],
      "Académie de Lille": [
        { "59": 'Nord' },
        { "62": 'Pas-de-Calais' }
      ],
      "Académie de Créteil": [
        { "77": 'Seine-et-Marne' },
        { "93": 'Seine-Saint-Denis' },
        { "94": 'Val-de-Marne' }
      ],
      "Académie de Paris": [
        { "75": 'Paris' }
      ],
      "Académie de Versailles": [
        { "78": 'Yvelines' },
        { "91": 'Essonne' },
        { "92": 'Hauts-de-Seine' },
        { "95": "Val-d'Oise" }
      ],
      "Académie de Martinique": [
        { "972": 'Martinique' }
      ],
      "Académie de Normandie": [
        { "14": 'Calvados' },
        { "27": 'Eure' },
        { "50": 'Manche' },
        { "61": 'Orne' },
        { "76": 'Seine-Maritime' }
      ],
      "Académie de Bordeaux": [
        { "24": 'Dordogne' },
        { "33": 'Gironde' },
        { "40": 'Landes' },
        { "47": 'Lot-et-Garonne' },
        { "64": 'Pyrénées-Atlantiques' }
      ],
      "Académie de Limoges": [
        { "19": 'Corrèze' },
        { "23": 'Creuse' },
        { "87": 'Haute-Vienne' }
      ],
      "Académie de Poitiers": [
        { "16": 'Charente' },
        { "17": 'Charente-Maritime' },
        { "79": 'Deux-Sèvres' },
        { "86": 'Vienne' }
      ],
      "Académie de Montpellier": [
        { "11": 'Aude' },
        { "30": 'Gard' },
        { "34": 'Hérault' },
        { "48": 'Lozère' },
        { "66": 'Pyrénées-Orientales' }
      ],
      "Académie de Toulouse": [
        { "09": 'Ariège' },
        { "12": 'Aveyron' },
        { "31": 'Haute-Garonne' },
        { "32": 'Gers' },
        { "46": 'Lot' },
        { "65": 'Hautes-Pyrénées' },
        { "81": 'Tarn' },
        { "82": 'Tarn-et-Garonne' }
      ],
      "Académie de Nantes": [
        { "44": 'Loire-Atlantique' },
        { "49": 'Maine-et-Loire' },
        { "53": 'Mayenne' },
        { "72": 'Sarthe' },
        { "85": 'Vendée' }
      ],
      "Académie d'Aix-Marseille": [
        { "04": 'Alpes-de-Haute-Provence' },
        { "05": 'Hautes-Alpes' },
        { "13": 'Bouches-du-Rhône' },
        { "84": 'Vaucluse' }
      ],
      "Académie de Nice": [
        { "06": 'Alpes-Maritimes' },
        { "83": 'Var' }
      ]
    }.each do |academy_name, departments|
      academy = Academy.find_by(name: academy_name)

      departments.each do |department_hashes|
        department_hashes.each do |code, department_name|
          Department.find_by(name: department_name).update!(academy: academy)
          # Department.create!(name: department_name, code:, academy:)
          print ' .'
        end
      end
    end
  end

  desc 'add_missing_grades_to_former_internship_offers'
  task :add_missing_grades_to_former_internship_offers, [] => :environment do
    PrettyConsole.announce_task('Adding missing grades to former internship offers') do
      InternshipOffer.kept.find_each do |offer|
        next if offer.grades.include?(Grade.seconde)

        offer.grades = [Grade.seconde]
        offer.save
        print '.'
      end
    end
  end

  desc 'used when migrating 2024 to 2025'
  task :offers_renewed, [] => :environment do |args|
    PrettyConsole.announce_task('Renewing internship offers') do
      url = ENV.fetch('EMPLOYERS_CSV_URL', nil)
      return if url.nil?

      CSV.parse(URI.open(url).read) do |row|
        email = row[0]
        employer = Users::Employer.find_by(email: email)
        next if employer.nil?

        offers = employer.internship_offers
                         .kept
                         .where(hidden_duplicate: false)
        offers = offers.where(school_id: nil) if Rails.env.development?

        offers.find_each do |offer|
          PrettyConsole.print_in_green '.'
          next unless (offer.weeks & Week.in_the_future).empty?

          new_internship_offer = offer.dup

          weeks_to_add = []
          if new_internship_offer.period == 0
            weeks_to_add << SchoolTrack::Seconde.both_weeks
          elsif new_internship_offer.period == 1
            weeks_to_add << SchoolTrack::Seconde.first_week
          elsif new_internship_offer.period == 2
            weeks_to_add << SchoolTrack::Seconde.second_week
          end
          new_internship_offer.weeks = weeks_to_add.flatten
          new_internship_offer.grades = [Grade.seconde]
          new_internship_offer.weekly_hours = offer.weekly_hours
          new_internship_offer.save
          new_internship_offer.publish!

          offer.hidden_duplicate = true
          offer.weeks = offer.weeks & Week.of_past_school_years
          if offer.weeks.empty? || !offer.valid?
            print 'x'
            CSV.open(Rails.root.join('storage/tmp/errors_when_duplicating_offers.csv'), 'a') do |csv|
              csv << [offer.id, email, offer.grades.map(&:name).join(', '),
                      offer.errors.full_messages.join(', ')]
            end
          else
            offer.save
            offer.unpublish! unless offer.unpublished?
            print '.'
          end
        end
      end
    end
  end

  desc 'populate grades'
  task populate_grades: :environment do
    Grade.find_or_create_by!(short_name: :seconde, name: 'seconde générale et technologique',
                             school_year_end_month: '06', school_year_end_day: '30')
    Grade.find_or_create_by!(short_name: :troisieme, name: 'troisieme générale', school_year_end_month: '05',
                             school_year_end_day: '31')
    Grade.find_or_create_by!(short_name: :quatrieme, name: 'quatrieme générale',
                             school_year_end_month: '05', school_year_end_day: '31')
  end
end
