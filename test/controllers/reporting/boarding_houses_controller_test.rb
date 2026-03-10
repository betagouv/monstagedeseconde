# frozen_string_literal: true

require 'test_helper'

module Reporting
  class BoardingHousesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      # Use academy that owns département 75 (Paris)
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

    test 'GET index as academy_statistician succeeds' do
      sign_in(@academy_statistician)
      get reporting_boarding_houses_path
      assert_response :success
    end

    # -- CRUD --

    test 'GET new as academy_statistician succeeds' do
      sign_in(@academy_statistician)
      get new_reporting_boarding_house_path
      assert_response :success
    end

    test 'POST create as academy_statistician creates boarding house' do
      sign_in(@academy_statistician)
      Geocoder.stub(:coordinates, [48.8566, 2.3522]) do
        assert_difference('BoardingHouse.count', 1) do
          post reporting_boarding_houses_path, params: {
            boarding_house: {
              name: 'Internat Test',
              street: '1 rue de Test',
              zipcode: '75001',
              city: 'Paris',
              contact_phone: '0100000000',
              contact_email: 'test@example.com',
              available_places: 10,
              reference_date: '2026-06-15'
            }
          }
        end
      end
      assert_redirected_to reporting_boarding_houses_path
    end

    test 'POST create with invalid params renders new' do
      sign_in(@academy_statistician)
      assert_no_difference('BoardingHouse.count') do
        post reporting_boarding_houses_path, params: {
          boarding_house: { name: '', zipcode: '', city: '' }
        }
      end
      assert_response :unprocessable_entity
    end

    test 'POST create with zipcode outside academy is rejected' do
      sign_in(@academy_statistician)
      Geocoder.stub(:coordinates, [44.8378, -0.5792]) do
        assert_no_difference('BoardingHouse.count') do
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
      assert_response :unprocessable_entity
    end

    test 'GET edit as academy_statistician succeeds' do
      sign_in(@academy_statistician)
      get edit_reporting_boarding_house_path(@boarding_house)
      assert_response :success
    end

    test 'PATCH update as academy_statistician updates boarding house' do
      sign_in(@academy_statistician)
      patch reporting_boarding_house_path(@boarding_house), params: {
        boarding_house: { name: 'Nouveau nom' }
      }
      assert_redirected_to reporting_boarding_houses_path
      assert_equal 'Nouveau nom', @boarding_house.reload.name
    end

    test 'DELETE destroy as academy_statistician deletes boarding house' do
      sign_in(@academy_statistician)
      assert_difference('BoardingHouse.count', -1) do
        delete reporting_boarding_house_path(@boarding_house)
      end
      assert_redirected_to reporting_boarding_houses_path
    end

    # -- Scoping --

    test 'cannot access boarding house from another academy' do
      bordeaux_dept = Department.fetch_by_zipcode(zipcode: '33000')
      other_bh = create(:boarding_house, academy: bordeaux_dept.academy,
                                         zipcode: '33000', city: 'Bordeaux')
      sign_in(@academy_statistician)
      get edit_reporting_boarding_house_path(other_bh)
      assert_response :not_found
    end
  end
end
