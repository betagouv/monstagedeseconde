import 'csv'
import 'pretty_console'

def create_craft_fields
  col_hash = {
    craft_field_letter: 0,
    craft: 1,
    detailed_craft: 2,
    name: 3,
    ogr_code: 4
  }
  file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
  file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127_light.csv')
  file_location = Rails.env.in?(%w[development review ]) ? file_location_review : file_location_production
  CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
    next if line_nr.zero?

    cells = row.to_s.split(';').map(&:strip)
    next unless cells[col_hash[:craft]].blank? && cells[col_hash[:detailed_craft]].blank?

    craft_field = CraftField.find_or_create_by(letter: cells[col_hash[:craft_field_letter]]) do |craft_field|
      PrettyConsole.print_in_green "."
      craft_field.name = cells[col_hash[:name]]
      craft_field.letter = cells[col_hash[:craft_field_letter]]
    end
  end
  puts ""
  PrettyConsole.say_in_yellow "Done with creating craft fields"
end

def create_crafts
  col_hash = {
    craft_field_letter: 0,
    craft: 1,
    detailed_craft: 2,
    name: 3,
    ogr_code: 4
  }
  file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
  file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127_light.csv')
  file_location = Rails.env.in?(%w[development review ]) ? file_location_review : file_location_production
  CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
    next if line_nr.zero?

    cells = row.to_s.split(';').map(&:strip)
    next if cells[col_hash[:craft]].blank? && cells[col_hash[:detailed_craft]].blank?
    next unless cells[col_hash[:detailed_craft]].blank?
    Craft.joins(:craft_field)
          .where(number: cells[col_hash[:craft]])
          .where(craft_field: {letter: cells[col_hash[:craft_field_letter]]})
          .first_or_create do |craft|
      PrettyConsole.print_in_green "."
      craft.name = cells[col_hash[:name]]
      craft.number = cells[col_hash[:craft]]
      craft_field = CraftField.find_by(letter: cells[col_hash[:craft_field_letter]])
      craft.craft_field = craft_field
    end
  end
  puts ""
  PrettyConsole.say_in_yellow "Done with creating crafts"
end

def create_detailed_crafts
  col_hash = {
    craft_field_letter: 0,
    craft: 1,
    detailed_craft: 2,
    name: 3,
    ogr_code: 4
  }
  file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
  file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127_light.csv')
  file_location = Rails.env.in?(%w[development review ]) ? file_location_review : file_location_production
  CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
    next if line_nr.zero?

    cells = row.to_s.split(';').map(&:strip)
    next if cells[col_hash[:craft]].blank? || cells[col_hash[:detailed_craft]].blank?
    next unless cells[col_hash[:ogr_code]].blank?


    DetailedCraft.joins(craft: :craft_field)
                  .where(craft: {number: cells[col_hash[:craft]]})
                  .where(craft_field: {letter: cells[col_hash[:craft_field_letter]]})
                  .where(number: cells[col_hash[:detailed_craft]])
                  .first_or_create do |detailed_craft|
      PrettyConsole.print_in_green "."
      detailed_craft.name = cells[col_hash[:name]]
      detailed_craft.number = cells[col_hash[:detailed_craft]]
      craft = Craft.find_by(number: cells[col_hash[:craft]])
      detailed_craft.craft = craft
    end
  end
  puts ""
  PrettyConsole.say_in_yellow "Done with creating detailed crafts"
end

def create_coded_crafts
  col_hash = {
    craft_field_letter: 0,
    craft: 1,
    detailed_craft: 2,
    name: 3,
    ogr_code: 4
  }
  file_location_production = Rails.root.join('db/data_imports/ROME_Arbo_20231127.csv')
  file_location_review = Rails.root.join('db/data_imports/ROME_Arbo_20231127_light.csv')
  file_location = Rails.env.in?(%w[development review ]) ? file_location_review : file_location_production
  CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
    next if line_nr.zero?

    cells = row.to_s.split(';').map(&:strip)
    next if cells[col_hash[:craft]].blank? || cells[col_hash[:detailed_craft]].blank?
    next if cells[col_hash[:ogr_code]].blank?

    CodedCraft.joins(detailed_craft: {craft: :craft_field})
              .where(detailed_craft: {number: cells[col_hash[:detailed_craft]]})
              .where(craft: {number: cells[col_hash[:craft]]})
              .where(craft_field: {letter: cells[col_hash[:craft_field_letter]]})
              .where(ogr_code: cells[col_hash[:ogr_code]])
              .first_or_create(ogr_code: cells[col_hash[:ogr_code]]) do |coded_craft|
      PrettyConsole.print_in_green "."
      coded_craft.name = cells[col_hash[:name]]
      coded_craft.ogr_code = cells[col_hash[:ogr_code]]
      detailed_craft = DetailedCraft.find_by(number: cells[col_hash[:detailed_craft]])
      coded_craft.detailed_craft = detailed_craft
    end
  end
  puts ""
  PrettyConsole.say_in_yellow "Done with creating coded crafts"
end

call_method_with_metrics_tracking([:create_craft_fields])
call_method_with_metrics_tracking([:create_crafts])
call_method_with_metrics_tracking([:create_detailed_crafts])
call_method_with_metrics_tracking([:create_coded_crafts])