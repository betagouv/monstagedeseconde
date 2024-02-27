namespace :data_migrations do
  desc 'create sectors'
  task add_sectors: :environment do
    {
      "Agroéquipement" => "s1",
      "Architecture, urbanisme et paysage" => "s2",
      "Armée - Défense" => "s3",
      "Art et design" => "s4",
      "Artisanat d'art" => "s5",
      "Arts du spectacle" => "s6",
      "Audiovisuel" => "s7",
      "Automobile" => "s8",
      "Banque et assurance" => "s9",
      "Bâtiment et travaux publics (BTP)" => "s10",
      "Bien-être" => "s11",
      "Commerce et distribution" => "s12",
      "Communication" => "s13",
      "Comptabilité, gestion, ressources humaines" => "s14",
      "Conseil et audit" => "s15",
      "Construction aéronautique, ferroviaire et navale" => "s16",
      "Culture et patrimoine" => "s17",
      "Droit et justice" => "s18",
      "Édition, librairie, bibliothèque" => "s19",
      "Électronique" => "s20",
      "Énergie" => "s21",
      "Enseignement" => "s22",
      "Environnement" => "s23",
      "Filiere bois" => "s24",
      "Fonction publique" => "s25",
      "Hôtellerie, restauration" => "s26",
      "Immobilier, transactions immobilières" => "s27",
      "Industrie alimentaire" => "s28",
      "Industrie chimique" => "s29",
      "Industrie, ingénierie industrielle" => "s30",
      "Informatique et réseaux" => "s31",
      "Jeu vidéo" => "s32",
      "Journalisme" => "s33",
      "Logistique et transport" => "s34",
      "Logistique et transport" => "s35",
      "Maintenance" => "s36",
      "Marketing, publicité" => "s37",
      "Mécanique" => "s38",
      "Métiers d'art" => "s39",
      "Mode" => "s40",
      "Papiers Cartons" => "s41",
      "Paramédical" => "s42",
      "Recherche" => "s43",
      "Santé" => "s44",
      "Sécurité" => "s45",
      "Services postaux" => "s46",
      "Social" => "s47",
      "Sport" => "s48",
      "Tourisme" => "s49",
      "Traduction, interprétation" => "s50",
      "Verre, béton, céramique" => "s51"
    }.map do |sector_name, sector_uuid|
      next if Sector.find_by(name: sector_name)

      Sector.create!(name: sector_name, uuid: sector_uuid)
      print "."
    end
  end
end