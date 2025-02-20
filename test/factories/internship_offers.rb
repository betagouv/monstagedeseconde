# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer, aliases: %i[with_public_group_internship_offer] do
    employer
    internship_occupation { create(:internship_occupation, employer: employer) }
    entreprise { create(:entreprise, internship_occupation: internship_occupation) }
    planning { create(:planning, entreprise: entreprise) }
    sequence(:title) { |n| "Stage de 2de - #{n}" }
    description { 'Lorem ipsum dolor' }
    contact_phone { '+330612345678' }
    max_candidates { 1 }
    blocked_weeks_count { 0 }
    sector { create(:sector) }
    school_year { SchoolYear::Current.year_in_june }
    is_public { true }
    group { create(:group, is_public: true) }
    internship_offer_area { create(:area, employer_id: employer.id, employer_type: 'User') }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    internship_address_manual_enter { false }
    city { 'Paris' }
    employer_name { 'Octo' }
    department { Department.find_by(code: '75') }
    coordinates { Coordinates.paris }
    entreprise_coordinates { Coordinates.paris }
    entreprise_full_address { '1 rue du poulet, 75001 Paris' }
    weeks { Week.both_school_track_weeks }
    siret { '11122233300000' }
    aasm_state { 'published' }
    hidden_duplicate { false }
    handicap_accessible { false }
    workspace_conditions { FFaker::Lorem.paragraph }
    workspace_accessibility { FFaker::Lorem.paragraph }
    daily_hours do
      {
        'lundi' => ['09:00', '17:00'],
        'mardi' => ['09:00', '17:00'],
        'mercredi' => ['09:00', '17:00'],
        'jeudi' => ['09:00', '17:00'],
        'vendredi' => ['09:00', '17:00']
      }
    end
    weekly_hours { [] }
    lunch_break { '12:00-13:00 avec le repas que vous apporterez' }
    grades { Grade.all }
    rep { false }
    qpv { false }

    trait :public do
      is_public { true }
      group { create(:group, is_public: true) }
    end

    trait :published do
      published_at { Time.now }
      aasm_state { 'published' }
    end

    trait :week_1 do
      grades { [Grade.seconde] }
      first_date { SchoolTrack::Seconde.current_period_data.dig(:week_1, :start_day) }
      last_date { SchoolTrack::Seconde.current_period_data.dig(:week_1, :end_day) }
      weeks { [SchoolTrack::Seconde.first_week] }
    end

    trait :week_2 do
      grades { [Grade.seconde] }
      first_date { SchoolTrack::Seconde.current_period_data.dig(:week_2, :start_day) }
      last_date { SchoolTrack::Seconde.current_period_data.dig(:week_2, :end_day) }
      weeks { [SchoolTrack::Seconde.second_week] }
    end

    trait :both_weeks do
      grades { [Grade.seconde] }
      first_date { SchoolTrack::Seconde.current_period_data.dig(:full_time, :start_day) }
      last_date { SchoolTrack::Seconde.current_period_data.dig(:full_time, :end_day) }
      weeks { SchoolTrack::Seconde.both_weeks }
    end

    trait :troisieme_generale_internship_offer do
      sequence(:title) { |n| "Stage de 3eme - #{n}" }
      weeks { Week.troisieme_selectable_weeks }
      grades { [Grade.troisieme] }
      first_date { weeks.first.monday }
      last_date { weeks.last.monday + 5.days }
    end

    trait :both_school_tracks_internship_offer do
      weeks { Week.both_school_track_weeks }
      grades { [Grade.seconde, Grade.troisieme] }
      first_date { Week.troisieme_selectable_weeks.first.monday }
      last_date { SchoolTrack::Seconde.current_period_data.dig(:full_time, :end_day) }
    end

    trait :draft do
      published_at { nil }
      aasm_state { 'drafted' }
    end

    trait :unpublished do
      published_at { nil }
      aasm_state { 'unpublished' }
    end

    trait :weekly_internship_offer do
      description { 'Lorem ipsum dolor weekly_internship_offer' }
      remaining_seats_count { max_candidates }
    end

    trait :api_internship_offer do
      permalink { 'https://google.fr' }
      description { 'Lorem ipsum dolor api' }
      sequence(:remote_id) { |n| n }
      employer { create(:user_operator) }
      internship_offer_area { employer.current_area }
    end

    trait :weekly_internship_offer_by_statistician do
    end

    trait :discarded do
      discarded_at { Time.now }
    end

    trait :unpublished do
      after(:create) { |offer| offer.update(published_at: nil) }
    end

    trait :with_private_employer_group do
      is_public { false }
      group { create(:group, is_public: false) }
    end

    trait :with_public_group do
      is_public { true }
      group { create(:group, is_public: true) }
    end

    trait :with_rep do
      rep { true }
    end

    trait :with_qpv do
      qpv { true }
    end

    # Seconde :
    factory :api_internship_offer_2nde, traits: %i[api_internship_offer week_1],
                                        class: 'InternshipOffers::Api',
                                        parent: :internship_offer

    factory :weekly_internship_offer_2nde, traits: %i[weekly_internship_offer published week_1],
                                           class: 'InternshipOffers::WeeklyFramed',
                                           parent: :internship_offer

    factory :weekly_internship_offer_by_statistician_2nde, traits: %i[weekly_internship_offer_by_statistician week_1],
                                                           class: 'InternshipOffers::WeeklyFramed',
                                                           parent: :internship_offer
    # Troisième :
    factory :api_internship_offer_3eme, traits: %i[api_internship_offer troisieme_generale_internship_offer],
                                        class: 'InternshipOffers::Api',
                                        parent: :internship_offer

    factory :weekly_internship_offer_3eme, traits: %i[weekly_internship_offer published troisieme_generale_internship_offer],
                                           class: 'InternshipOffers::WeeklyFramed',
                                           parent: :internship_offer

    factory :weekly_internship_offer_by_statistician_3eme, traits: %i[weekly_internship_offer_by_statistician troisieme_generale_internship_offer],
                                                           class: 'InternshipOffers::WeeklyFramed',
                                                           parent: :internship_offer
    # Both school tracks :
    factory :api_internship_offer, traits: %i[api_internship_offer both_school_tracks_internship_offer],
                                   class: 'InternshipOffers::Api',
                                   parent: :internship_offer

    factory :weekly_internship_offer, traits: %i[weekly_internship_offer published both_school_tracks_internship_offer],
                                      class: 'InternshipOffers::WeeklyFramed',
                                      parent: :internship_offer

    factory :weekly_internship_offer_by_statistician, traits: %i[weekly_internship_offer_by_statistician both_school_tracks_internship_offer],
                                                      class: 'InternshipOffers::WeeklyFramed',
                                                      parent: :internship_offer
  end
end
