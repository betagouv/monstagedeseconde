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
      format_weeks do |is_first:, is_last:, week:|
        if is_first
          week.beginning_of_week_with_year_long
        elsif is_last
          week.end_of_working_week_with_year
        else
          week.very_long_working_week_select_text_method
        end
      end
    end

    def to_range(&block)
      format_weeks(&block)
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

    def str_weeks_display
      troisieme_weeks = weeks & Week.selectable_from_now_until_next_school_year # TODO: remove this in july 2025
      seconde_weeks = weeks & Week.seconde_selectable_weeks
      label_troisieme_weeks = nil
      label_seconde_weeks = nil

      if troisieme_weeks.present?
        troisieme_week_list = self.class.new(weeks: troisieme_weeks)
        label_troisieme_weeks = "Disponible une semaine du #{troisieme_week_list.first_week.beginning_of_week_abr} au #{troisieme_week_list.last_week.end_of_working_week_with_year}"
      end

      if seconde_weeks.present?
        second_week_list = self.class.new(weeks: seconde_weeks)
        if seconde_weeks.count == 2
          # label_seconde_weeks = "Disponible pour un stage de 2 semaines du #{first_week.monday} au #{last_week.friday}"
          label_seconde_weeks = 'Disponible pour un stage de 2 semaines'
        elsif seconde_weeks.count == 1
          label_seconde_weeks = 'Disponible pour une semaine de stage '
        end
        label_seconde_weeks = "#{label_seconde_weeks} du #{second_week_list.first_week.beginning_of_week_abr} au #{second_week_list.last_week.end_of_working_week_with_year}"
      end
      [label_troisieme_weeks, label_seconde_weeks].compact
    end

    def split_range_string
      to_range_as_str.split(/(\d*\s?semaines?\s?:?)/)
    end

    def to_api_formatted
      weeks.map(&:long_select_text_method)
           .join(', ')
    end

    def detailed_attributes
      weeks.map do |week|
        {
          id: week.id,
          number: week.number,
          month: week.month_number,
          monthName: MONTHS[week.month_number - 1],
          year: week.year,
          label: week.human_shortest
        }
      end
    end

    attr_reader :weeks, :first_week, :last_week

    protected

    def format_weeks(&block)
      case weeks.size
      when 0
        ''
      when 1
        render_week_range(
          prefix: 'Disponible la semaine ',
          first_week: first_week,
          last_week: first_week,
          &block
        )
      else
        render_week_range(
          prefix: "Disponible sur #{weeks.size} semaines : ",
          first_week: first_week,
          last_week: last_week,
          &block
        )
      end
    end

    def render_week_range(prefix:, first_week:, last_week:, &block)
      [
        prefix,
        yield(is_first: true, is_last: false, week: first_week),
        " → #{yield(is_first: false, is_last: true, week: last_week)}"
      ].join.gsub(/\s+/, ' ').html_safe
    end

    private

    def initialize(weeks:)
      @weeks = weeks
      @single_week = weeks.try(:size) == 1
      if weeks.present? && weeks.size > 1
        @first_week, @last_week = weeks.minmax_by(&:id)
      elsif @single_week
        @first_week = @last_week = weeks.first
      else
        @first_week = @last_week = nil
      end
    end
  end
end
