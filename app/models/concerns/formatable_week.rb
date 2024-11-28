# frozen_string_literal: true

module FormatableWeek
  extend ActiveSupport::Concern

  included do
    # to, strip, join with space otherwise multiple spaces can be outputted,
    # then within html it is concatenated [html logic], but capybara fails to find this content
    def short_select_text_method
      ['du', beginning_of_week, 'au', end_of_working_week]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def short_range_as_str
      [
        I18n.localize(week_date.beginning_of_week, format: '%e %B'),
        ' ➝ ',
        I18n.localize(week_date.end_of_week, format: '%e %B')
      ].join('')
    end

    alias_method :to_s, :short_range_as_str

    def long_select_text_method
      ['du', beginning_of_week_with_year, 'au', end_of_week_with_years]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def very_long_select_text_method
      ['du', beginning_of_week_with_year_long, 'au', end_of_week_with_years_long]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def human_select_text_method
      ['Semaine du', beginning_of_week, 'au', end_of_week]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def select_text_method
      ['Du', beginning_of_week_with_short_month_year_long, 'au', end_of_week_with_short_month_years_long,
       "[Sem - #{number}]"]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end

    def select_text_method_with_year
      ['Semaine', number, '- du', beginning_of_week, 'au', end_of_week, year]
        .map(&:to_s)
        .map(&:strip)
        .join(' ')
    end
    alias_method :to_str, :select_text_method_with_year

    def human_shortest
      same_month = week_date.month == week_date.end_of_week.month
      beginning = same_month ? week_date.day.to_s : beginning_of_week_abr
      ending    = same_month ? end_of_week : end_of_week_abr
      ['du', beginning, 'au', ending].map(&:strip).join(' ')
    end

    def week_date
      Date.commercial(year, number)
    end
    alias_method :date, :week_date
    alias_method :to_date, :week_date
    alias_method :monday, :week_date

    def beginning_of_week(format: :human_mm_dd)
      I18n.localize(week_date.beginning_of_week, format:).strip
    end

    def beginning_of_week_short(format: :human_mm_dd)
      I18n.localize(week_date.beginning_of_week, format: :human_mm_dd).strip
    end

    def beginning_of_week_with_year
      I18n.localize(week_date.beginning_of_week, format: :default).strip
    end

    def beginning_of_week_with_year_long
      I18n.localize(week_date.beginning_of_week, format: :human_mm_dd_yyyy).strip
    end

    def beginning_of_week_with_short_month_year_long
      I18n.localize(week_date.beginning_of_week, format: :human_dd_short_mm_yyyy).strip
    end

    def beginning_of_week_abr
      I18n.localize(week_date.beginning_of_week, format: :human_dd_mm).strip
    end

    def end_of_week(format: :human_mm_dd)
      I18n.localize(week_date.end_of_week, format:).strip
    end

    def end_of_week_abr
      I18n.localize(week_date.end_of_week, format: :human_dd_mm).strip
    end

    def end_of_working_week
      I18n.localize(week_date.end_of_week - 2.days, format: :human_mm_dd).strip
    end

    def end_of_week_with_years
      I18n.localize(week_date.end_of_week, format: :default).strip
    end

    def end_of_week_with_years_long
      I18n.localize(week_date.end_of_week, format: :human_mm_dd_yyyy).strip
    end

    def friday_of_week_with_years_long
      I18n.localize(week_date + 4, format: :human_mm_dd_yyyy).strip
    end

    def end_of_week_with_short_month_years_long
      I18n.localize(week_date.end_of_week, format: :human_dd_short_mm_yyyy).strip
    end

    def month_number
      monday = week_date.beginning_of_week
      wednesday = monday + 2.day
      return monday.month if monday.month == wednesday.month

      wednesday.month
    end

    def month_number
      monday = week_date.beginning_of_week
      tuesday = monday + 1.day
      wednesday = tuesday + 1.day
      return monday.month if monday.month == tuesday.month && tuesday.month == wednesday.month

      (monday + 4.days).month
    end
  end
end
