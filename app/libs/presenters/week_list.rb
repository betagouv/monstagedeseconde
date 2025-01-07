# frozen_string_literal: true

module Presenters
  # render a lit of week easily with folding of internval
  class WeekList
    MONTHS = %w[Janvier Février Mars Avril Mai Juin Juillet Aout Septembre Octobre Novembre Décembre].freeze

    # [ {month: 9, name: 'Septembre'} ,{ month: 10, }...]
    MONTH_LIST =
      MONTHS.each_with_index.map { |month, index| { month: index + 1, name: month } }
            .rotate(8).freeze

    def to_range_as_str
      to_range do |is_first:, is_last:, week:|
        if is_first
          week.beginning_of_week_with_year_long
        elsif is_last
          week.end_of_week_with_years_long
        else
          week.very_long_select_text_method
        end
      end
    end

    def to_range(&block)
      case weeks.size
      when 0
        ''
      when 1
        render_first_week_only(&block)
      else
        render_by_collapsing_date_from_first_to_last_week(&block)
      end
    end

    def split_weeks_in_trunks(basic: false)
      container = []
      week_list = weeks.dup.to_a.sort_by(&:id)
      while week_list.present?
        joined_weeks = [week_list.shift]
        joined_weeks << week_list.shift while week_list.present? && week_list.first.consecutive_to?(joined_weeks.last)
        container << (basic ? joined_weeks : self.class.new(weeks: joined_weeks))
      end
      container
    end

    # @return [Hash{ month_number: Array[weeks belonging to month_number]}]
    def month_split
      weeks.group_by(&:month_number)
    end

    def to_s
      to_range_as_str
    end

    def empty?
      weeks.empty?
    end

    def split_range_string
      to_range_as_str.split(/(\d*\s?semaines?\s?:?)/)
    end

    def to_api_formatted
      weeks.map(&:long_select_text_method)
           .join(', ')
    end

    attr_reader :weeks, :first_week, :last_week

    protected

    def render_first_week_only
      [
        'Disponible la semaine ',
        yield(is_first: false, is_last: false, week: first_week).strip
      ].join.gsub(/\s+/, ' ').html_safe
    end

    def render_by_collapsing_date_from_first_to_last_week
      [
        "Disponible sur #{weeks.size} semaines :",
        yield(is_first: true, is_last: false, week: first_week),
        " → #{yield(is_first: false, is_last: true, week: last_week)}"
      ].join.gsub(/\s+/, ' ').html_safe
    end

    private

    def initialize(weeks:)
      @weeks = weeks
      @first_week, @last_week = weeks.minmax_by(&:id)
    end
  end
end
