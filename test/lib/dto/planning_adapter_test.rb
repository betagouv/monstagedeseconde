# frozen_string_literal: true

require 'test_helper'

module Dto
  class PlanningAdapterTest < ActiveSupport::TestCase
    def adapter_for(instance, params)
      PlanningAdapter.new(instance:, params:, current_user: nil)
    end

    test 'manage_grades keeps college grades outside the closed period' do
      travel_to Date.new(2025, 1, 15) do
        instance = Planning.new
        adapter_for(instance, grade_college: '1', grade_2e: '0').manage_grades

        assert_equal Grade.troisieme_et_quatrieme.ids.sort, instance.grades.map(&:id).sort
      end
    end

    test 'manage_grades drops college grades during the closed period' do
      travel_to Date.new(2025, 6, 15) do
        instance = Planning.new
        adapter_for(instance, grade_college: '1', grade_2e: '0').manage_grades

        assert_empty instance.grades
      end
    end

    test 'manage_grades keeps seconde while dropping college during the closed period' do
      travel_to Date.new(2025, 6, 15) do
        instance = Planning.new
        adapter_for(instance, grade_college: '1', grade_2e: '1').manage_grades

        assert_equal [Grade.seconde.id], instance.grades.map(&:id)
      end
    end

    test 'manage_grades strips college grades carried over via grade_ids when closed' do
      travel_to Date.new(2025, 6, 15) do
        instance = Planning.new(grades: Grade.troisieme_et_quatrieme.to_a)
        # No checkbox params: mimics a duplication/renewal carrying grade_ids.
        adapter_for(instance, {}).manage_grades

        assert_empty instance.grades
      end
    end

    test 'manage_grades keeps college grades carried over via grade_ids when open' do
      travel_to Date.new(2025, 1, 15) do
        instance = Planning.new(grades: Grade.troisieme_et_quatrieme.to_a)
        adapter_for(instance, {}).manage_grades

        assert_equal Grade.troisieme_et_quatrieme.ids.sort, instance.grades.map(&:id).sort
      end
    end

    test 'manage_grades keeps grades of a persisted college offer edited during the closed period' do
      # Editing (not creating): the edit form omits grade checkboxes, so the
      # existing college grades must be left untouched even while closed.
      planning = travel_to(Date.new(2025, 1, 15)) { create(:planning, :with_troisieme_only) }

      travel_to Date.new(2025, 6, 15) do
        adapter_for(planning, {}).manage_grades

        assert_includes planning.grades.map(&:id), Grade.troisieme.id
      end
    end
  end
end
