# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer, aliases: %i[with_public_group_internship_offer] do
    employer
    internship_occupation { create(:internship_occupation, employer: employer) }
    entreprise { create(:entreprise, internship_occupation: internship_occupation) }
    planning { create(:planning, entreprise: entreprise) }
    sequence(:title) { |n| "Stage de 2de - #{n}" }
    description { 'Lorem ipsum dolor' }
    # contact_phone { '+330612345678' }
    max_candidates { 1 }
    blocked_weeks_count { 0 }
    sector { create(:sector) }
    school_year { SchoolYear::Current.year_in_june }
    is_public { true }
    group { create(:group, is_public: true) }
    internship_offer_area { create(:area, employer_id: employer.id, employer_type: 'User') }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    employer_name { 'Octo' }
    department { Department.find_by(code: '75') }
    coordinates { Coordinates.paris }
    entreprise_coordinates { Coordinates.paris }
    entreprise_full_address { '1 rue du poulet, 75001 Paris' }

    siret { '11122233300000' }
    aasm_state { 'published' }
    hidden_duplicate { false }
    handicap_accessible { false }
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
    weeks { Week.selectable_from_now_until_end_of_school_year }
    grades { Grade.all }

    trait :drafted do
      aasm_state { :drafted }
    end

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

    trait :troisieme_generale_internship_offer do
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

    # after(:create) do |internship_offer, params|
    #  create(:internship_offer_stats, internship_offer: internship_offer)
    # end

    factory :api_internship_offer_2nde, traits: %i[api_internship_offer week_1],
                                        class: 'InternshipOffers::Api',
                                        parent: :internship_offer

    factory :weekly_internship_offer_2nde, traits: %i[weekly_internship_offer published week_1],
                                           class: 'InternshipOffers::WeeklyFramed',
                                           parent: :internship_offer

    factory :weekly_internship_offer_by_statistician_2nde, traits: %i[weekly_internship_offer_by_statistician week_1],
                                                           class: 'InternshipOffers::WeeklyFramed',
                                                           parent: :internship_offer
    factory :api_internship_offer_3eme, traits: %i[api_internship_offer],
                                        class: 'InternshipOffers::Api',
                                        parent: :internship_offer

    factory :weekly_internship_offer_3eme, traits: %i[weekly_internship_offer published],
                                           class: 'InternshipOffers::WeeklyFramed',
                                           parent: :internship_offer

    factory :weekly_internship_offer_by_statistician_3eme, traits: %i[weekly_internship_offer_by_statistician],
                                                           class: 'InternshipOffers::WeeklyFramed',
                                                           parent: :internship_offer
  end
end
