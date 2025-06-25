# frozen_string_literal: true

module SchoolYear
  # period from beginning of school year until end
  class Current < Base
    # 2024/2025 2025 is year_in_june
    def year_in_june = deposit_end_of_period.year
    def self.year_in_june = new.year_in_june

    private

    def initialize
      @date = Date.today
    end
  end
end
