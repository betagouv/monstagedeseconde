# frozen_string_literal: true

FactoryBot.define do
  factory :naf_sector_mapping do
    code_naf { '62.01Z' }
    sector
    date_start { Date.new(2020, 1, 1) }
    date_end { Date.new(2030, 12, 31) }
  end
end
