module ReviewRebuild
  module BoardingHousesCreationSteps # and Users::Operators
    extend ActiveSupport::Concern
    def create_boarding_houses
      boarding_houses_data = [
        { name: "Internat du Lycée Henri-IV",         street: "23 rue Clovis",
          zipcode: "75005", city: "Paris",
          latitude: 48.846611, longitude: 2.348078,  available_places: 80 },
        { name: "Internat du Lycée du Parc",          street: "1 boulevard Anatole France",
          zipcode: "69006", city: "Lyon",
          latitude: 45.770870, longitude: 4.847119,  available_places: 65 },
        { name: "Internat du Lycée Thiers",           street: "5 place du Lycée",
          zipcode: "13001", city: "Marseille",
          latitude: 43.298510, longitude: 5.385640,  available_places: 90 },
        { name: "Internat du Lycée Pierre-de-Fermat", street: "Parvis des Jacobins",
          zipcode: "31000", city: "Toulouse",
          latitude: 43.601501, longitude: 1.443058,  available_places: 70 },
        { name: "Internat du Lycée Albert-Calmette",  street: "33 avenue de Californie",
          zipcode: "06200", city: "Nice",
          latitude: 43.690330, longitude: 7.244260,  available_places: 50 },
        { name: "Internat du Lycée Clemenceau",       street: "1 rue Georges-Clemenceau",
          zipcode: "44000", city: "Nantes",
          latitude: 47.220530, longitude: -1.554800, available_places: 60 },
        { name: "Internat du Lycée Kléber",           street: "25 place de Bordeaux",
          zipcode: "67000", city: "Strasbourg",
          latitude: 48.595800, longitude: 7.755870,  available_places: 55 },
        { name: "Internat du Lycée Faidherbe",        street: "9 rue Armand-Carrel",
          zipcode: "59000", city: "Lille",
          latitude: 50.629820, longitude: 3.073550,  available_places: 75 },
        { name: "Internat du Lycée Émile-Zola",       street: "2 avenue Janvier",
          zipcode: "35000", city: "Rennes",
          latitude: 48.105270, longitude: -1.673660, available_places: 45 },
        { name: "Internat du Lycée Joffre",           street: "150 allée de la Citadelle",
          zipcode: "34000", city: "Montpellier",
          latitude: 43.614520, longitude: 3.870650,  available_places: 85 }
      ]

      boarding_houses = boarding_houses_data.map do |attrs|
        bh = BoardingHouse.new(attrs.merge(
          contact_phone: "+330#{(100_000_000..999_999_999).to_a.sample}",
          contact_email: "contact-#{attrs[:zipcode]}@internat.fr",
          reference_date: Date.today - rand(0..60).days
        ))

        dept = Department.fetch_by_zipcode(zipcode: bh.zipcode)
        bh.academy = dept.academy if dept

        bh.save!
        bh
      end

      # Quelques stats correspondantes : vues de fiches (authentifiées et anonymes).
      user_pool = Users::Student.limit(5).to_a + [ nil, nil, nil ]
      boarding_houses.each do |bh|
        rand(3..15).times do
          BoardingHouseView.create!(
            boarding_house: bh,
            user: user_pool.sample,
            latitude: bh.latitude + (rand - 0.5) * 0.1,
            longitude: bh.longitude + (rand - 0.5) * 0.1,
            radius: [ 10_000, 30_000, 60_000 ].sample,
            created_at: rand(0..30).days.ago
          )
        end
      end
    end
  end
end
