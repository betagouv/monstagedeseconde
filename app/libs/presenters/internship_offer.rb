include ActionView::Helpers::TagHelper
include ActionView::Context
module Presenters
  class InternshipOffer
    delegate :siret, to: :internship_offer
    def weeks_boundaries
      "Du #{first_monday} au #{last_friday}"
    end

    def first_monday
      I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy)
    end

    def last_friday
      I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy)
    end

    def employer_name
      internship_offer.employer_name
    end

    def address
      "#{internship_offer.street}, #{internship_offer.zipcode} #{internship_offer.city}"
    end

    def remaining_seats
      count = internship_offer.remaining_seats_count
      "#{count} #{'place'.pluralize(count)}"
    end

    def internship_week_description
      internship_offer.weekly_planning? ? internship_weekly_description : internship_daily_description
    end

    def internship_weekly_description
      hours = internship_offer.weekly_hours
      daily_schedule = ["#{hours[0]} à #{hours[1]}".gsub!(':', 'h')]

      content_tag(:div,
                  content_tag(:div, "#{daily_schedule.join(', ')}",
                              class: 'fr-tag fr-icon-calendar-fill fr-tag--icon-left'),
                  class: 'fr-mb-2w')
    end

    def internship_daily_description
      %w[lundi mardi mercredi jeudi vendredi].map do |day|
        hours = internship_offer.daily_hours&.[](day) || []
        next if hours.blank? || hours.size != 2

        daily_schedule = ["de #{hours[0]} à #{hours[1]}".gsub!(':', 'h')]

        content_tag(:div,
                    content_tag(:div, "#{day.capitalize} : #{daily_schedule.join(', ')}",
                                class: 'fr-tag fr-icon-calendar-fill fr-tag--icon-left'),
                    class: 'fr-mb-2w')
      end.join.html_safe
    end

    def formal_siret
      return 'N/A' unless siret.present?

      siret.gsub(/(\d{3})(\d{3})(\d{3})(\d{5})/, '\1 \2 \3 \4')
    end

    def weeks_description
      dates = "du #{first_monday} au #{last_friday}"
      case internship_offer.internship_weeks_number
      when 1
        "1 semaine #{dates}"
      when 2
        "2 semaines #{dates}"
      end
    end

    private

    attr_reader :internship_offer

    def initialize(internship_offer)
      @internship_offer = internship_offer
    end
  end
end
