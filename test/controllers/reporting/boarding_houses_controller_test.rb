# frozen_string_literal: true

require 'test_helper'

module Reporting
  class BoardingHousesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      paris_dept = Department.fetch_by_zipcode(zipcode: '75001')
      @academy = paris_dept.academy
      @academy_statistician = create(:academy_statistician, academy: @academy)
      @boarding_house = create(:boarding_house, academy: @academy)
    end

    # -- Authorization --

    test 'GET index as visitor redirects to sign in' do
      get reporting_boarding_houses_path
      assert_response :redirect
    end

    test 'GET index as academy_statistician is forbidden' do
      sign_in(@academy_statistician)
      get reporting_boarding_houses_path
      assert_redirected_to root_path
    end

    test 'GET edit as academy_statistician is forbidden' do
      sign_in(@academy_statistician)
      get edit_reporting_boarding_house_path(@boarding_house)
      assert_redirected_to root_path
    end

    test 'PATCH update as academy_statistician is forbidden' do
      sign_in(@academy_statistician)
      patch reporting_boarding_house_path(@boarding_house), params: {
        boarding_house: { name: 'Nouveau nom' }
      }
      assert_redirected_to root_path
      assert_not_equal 'Nouveau nom', @boarding_house.reload.name
    end

    test 'DELETE destroy as academy_statistician is forbidden' do
      sign_in(@academy_statistician)
      assert_no_difference('BoardingHouse.count') do
        delete reporting_boarding_house_path(@boarding_house)
      end
      assert_redirected_to root_path
    end

    test 'GET new as academy_statistician is redirected' do
      sign_in(@academy_statistician)
      get new_reporting_boarding_house_path
      assert_redirected_to reporting_boarding_houses_path
    end

    test 'POST create as academy_statistician is redirected' do
      sign_in(@academy_statistician)
      assert_no_difference('BoardingHouse.count') do
        post reporting_boarding_houses_path, params: {
          boarding_house: {
            name: 'Internat Test',
            zipcode: '75001',
            city: 'Paris'
          }
        }
      end
      assert_redirected_to reporting_boarding_houses_path
    end

    # -- God user --

    test 'GET index as god succeeds and shows all boarding houses' do
      god = create(:god)
      bordeaux_dept = Department.fetch_by_zipcode(zipcode: '33000')
      other_bh = create(:boarding_house, academy: bordeaux_dept.academy,
                                         zipcode: '33000', city: 'Bordeaux')
      sign_in(god)
      get reporting_boarding_houses_path
      assert_response :success
      assert_includes response.body, @boarding_house.name
      assert_includes response.body, other_bh.name
    end

    test 'POST create as god with any zipcode succeeds' do
      god = create(:god)
      sign_in(god)
      Geocoder.stub(:coordinates, [44.8378, -0.5792]) do
        assert_difference('BoardingHouse.count', 1) do
          post reporting_boarding_houses_path, params: {
            boarding_house: {
              name: 'Internat Bordeaux',
              street: '1 rue de Test',
              zipcode: '33000',
              city: 'Bordeaux',
              available_places: 5
            }
          }
        end
      end
      assert_redirected_to reporting_boarding_houses_path
      bh = BoardingHouse.last
      bordeaux_dept = Department.fetch_by_zipcode(zipcode: '33000')
      assert_equal bordeaux_dept.academy, bh.academy
    end

    test 'god can edit boarding house from any academy' do
      god = create(:god)
      bordeaux_dept = Department.fetch_by_zipcode(zipcode: '33000')
      other_bh = create(:boarding_house, academy: bordeaux_dept.academy,
                                         zipcode: '33000', city: 'Bordeaux')
      sign_in(god)
      get edit_reporting_boarding_house_path(other_bh)
      assert_response :success
    end

    test 'god can destroy boarding house from any academy' do
      god = create(:god)
      bordeaux_dept = Department.fetch_by_zipcode(zipcode: '33000')
      other_bh = create(:boarding_house, academy: bordeaux_dept.academy,
                                         zipcode: '33000', city: 'Bordeaux')
      sign_in(god)
      assert_difference('BoardingHouse.count', -1) do
        delete reporting_boarding_house_path(other_bh)
      end
      assert_redirected_to reporting_boarding_houses_path
    end
  end
end
