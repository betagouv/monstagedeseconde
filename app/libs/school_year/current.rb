# frozen_string_literal: true

module SchoolYear
  # period from beginning of school year until end
  class Current < Base
    # 2024/2025 2025 is year_in_june

    attr_reader :date

    private

    def initialize
      @date = Date.today
    end
  end
end
