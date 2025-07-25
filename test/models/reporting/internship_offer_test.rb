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
end
