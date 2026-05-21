module ReviewRebuild
  module BoardingHousesCreationSteps # and Users::Operators
    extend ActiveSupport::Concern
    def create_boarding_houses
      boarding_houses = BoardingHouse.all.to_a.shuffle.first(20) # for the sake of having some boarding_houses to work with, we take 20 random ones from the DB, which are created by seeds.rb

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
