module SearchHelper
  # def years_from_list_months_search
  #   return Date.today.year if list_months_for_search.blank?
    
  #   list_months = list_months_for_search.values.flatten
  #   year_start  = list_months.first.year
  #   year_end    = list_months.last.year
  #   year_start == year_end ? year_start : "#{year_start} - #{year_start + 1}"
  # end

  def search_button_label
    count = params.permit(:latitude, :keyword, :period)
                  .to_h
                  .map do |k,v|
                    v&.empty? ? 0 : 1
                  end
                  .sum
    count.zero? ? 'Rechercher' : "Modifier ma recherche (#{count})"
  end

end
