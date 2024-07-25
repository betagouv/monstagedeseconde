# frozen_string_literal: true

require 'test_helper'

module Finders
  class ReportingInternshipOfferTest < ActiveSupport::TestCase
    test '.total with department params filters offers by departement' do
      create(:department, code: '02', name: 'Aisne')
      finder = ReportingInternshipOffer.new(params: { department: 'Aisne' })
      assert_equal(0,
                   finder.total,
                   'should not find not offers by departement when no one had been')

      create(:weekly_internship_offer, zipcode: '02150')
      create(:weekly_internship_offer, zipcode: '02150')
      assert_equal(2,
                   finder.total,
                   'bad count of filtered offer by departement')
    end

    test '.total with dimension params group offers' do
      create(:weekly_internship_offer, group: nil)
      finder = ReportingInternshipOffer.new(params: { dimension: :group })
      assert_equal(1,
                   finder.total,
                   'should find offers with no group (labeled as independant)')

      public_group = create(:group, is_public: true)
      create(:weekly_internship_offer, group: public_group)
      assert_equal(2,
                   finder.total,
                   'should find offers with group')
    end

    test '.total with dimension sector group offers by sector' do
      finder = ReportingInternshipOffer.new(params: { dimension: :sector })
      sector = create(:sector)
      create(:weekly_internship_offer, sector:)
      assert_equal(1,
                   finder.total,
                   'should find offers with sector')
    end

    test '.total with academy params filters offers by school.academy' do
      academy = create(:academy, name: "Academy de l'Aisne")
      create(:department, code: '02', name: 'Aisne', academy:)
      create(:department, code: '60', name: 'Oise')
      create(:weekly_internship_offer, zipcode: '60000')
      finder = ReportingInternshipOffer.new(params: { academy: academy.name })
      assert_equal(0,
                   finder.total,
                   'should not find offers not in academy')
      create(:weekly_internship_offer, zipcode: '02000')
      assert_equal(1,
                   finder.total,
                   'should not find offers not in academy')
    end

    test '.total with is_public params filters offers by public' do
      private_group = create(:group, is_public: false)
      public_group = create(:group, is_public: true)
      offer = create(:weekly_internship_offer, is_public: public_group.is_public, group: public_group)
      finder = ReportingInternshipOffer.new(params: { is_public: private_group.is_public })
      assert_equal(0,
                   finder.total,
                   'should not find offers in a public group')
      create(:weekly_internship_offer, is_public: private_group.is_public, group: private_group)
      assert_equal(1,
                   finder.total,
                   'should find offers in a private group')
    end
  end
end
