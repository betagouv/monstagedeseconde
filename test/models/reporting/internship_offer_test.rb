# frozen_string_literal: true

require 'test_helper'

class ReportingInternshipOfferTest < ActiveSupport::TestCase
  test 'views can be queried' do
    3.times { create(:weekly_internship_offer_2nde) }
    assert_equal 3, Reporting::InternshipOffer.count
  end

  test '.dimension_by_sector group by sector_name' do
    sector_a = create(:sector, name: 'Agriculture')
    sector_b = create(:sector, name: 'Filière bois')
    2.times { create(:weekly_internship_offer_2nde, :private, sector: sector_a) }
    create(:weekly_internship_offer_2nde, :private, sector: sector_b)

    results = Reporting::InternshipOffer.dimension_by_sector
    first_sectored_report = results[0]
    last_sectored_report = results[1]

    assert_equal first_sectored_report.sector_name, sector_a.name
    assert_equal last_sectored_report.sector_name, sector_b.name
  end

  test '.dimension_by_sector sum max_candidates' do
    travel_to Date.new(2023, 10, 1) do
      sector_a = Sector.find_by(name: 'Agriculture')
      sector_b = Sector.find_by(name: 'Filiere bois')
      create(:weekly_internship_offer_3eme,
            :private,
             sector: sector_a,
             max_candidates: 3)
      create(:weekly_internship_offer_3eme,
            :private,
             sector: sector_a,
             max_candidates: 1)
      create(:weekly_internship_offer_3eme,
            :private,
             sector: sector_b,
             max_candidates: 10)

      results = Reporting::InternshipOffer.dimension_by_sector
      first_sectored_report = results[0]
      last_sectored_report = results[1]

      assert_equal 4, first_sectored_report.total_report_count
      assert_equal 10, last_sectored_report.total_report_count
    end
  end

  test '.during_year filters offers by school year' do
    school_year = SchoolYear::Current.new
    assert_equal 0, Reporting::InternshipOffer.during_year(school_year:).count

    o1 = create(:weekly_internship_offer_2nde)
    o1.update_columns(
      first_date: school_year.offers_beginning_of_period + 1.day,
      last_date: school_year.offers_beginning_of_period + 90.days
    )
    
    assert_equal 1, Reporting::InternshipOffer.during_year(school_year:).count

    # create an offer in the next school year
    o2 = create(:weekly_internship_offer_2nde)
    o2.update_columns(
      first_date: school_year.next_year.offers_beginning_of_period + 2.days,
      last_date: school_year.next_year.offers_beginning_of_period + 90.days
    )
  
    assert_equal 1, Reporting::InternshipOffer.during_year(school_year:).count
  end
end
