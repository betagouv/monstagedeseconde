# frozen_string_literal: true

module Services
  class BoardingHouseImporter
    COLUMN_MAPPING = {
      'nom' => :name,
      'adresse' => :street,
      'code postal' => :zipcode,
      'ville' => :city,
      'département' => :department,
      'departement' => :department,
      'téléphone' => :contact_phone,
      'telephone' => :contact_phone,
      'email' => :contact_email,
      'places disponibles' => :available_places,
      'date de référence' => :reference_date,
      'date de reference' => :reference_date
    }.freeze

    def initialize(file:, academy:)
      @file = file
      @academy = academy
    end

    def call
      spreadsheet = Roo::Spreadsheet.open(@file.path, extension: extension)
      headers = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }

      created = 0
      skipped = 0
      errors = []

      (2..spreadsheet.last_row).each do |i|
        row_data = map_row(headers, spreadsheet.row(i))
        if row_data[:name].blank?
          skipped += 1
          next
        end

        bh = if @academy
              @academy.boarding_houses.new(row_data)
            else
              BoardingHouse.new(row_data)
            end
        bh.available_places = bh.available_places.to_i
        bh.reference_date = parse_date(bh.reference_date) unless bh.reference_date.is_a?(Date)
        assign_academy_from_zipcode(bh) if @academy.nil?

        if bh.save
          created += 1
        else
          errors << { row: i, errors: bh.errors.full_messages }
        end
      end

      { created: created, errors: errors, skipped: skipped, total: spreadsheet.last_row - 1, headers: headers }
    end

    private

    def extension
      File.extname(@file.original_filename).delete('.')
    end

    def map_row(headers, row)
      result = {}
      headers.each_with_index do |header, index|
        attr = COLUMN_MAPPING[header]
        result[attr] = row[index] if attr
      end
      result
    end

    def parse_date(value)
      return nil if value.blank?
      return value if value.is_a?(Date)

      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    def assign_academy_from_zipcode(boarding_house)
      return if boarding_house.zipcode.blank?

      dept = Department.fetch_by_zipcode(zipcode: boarding_house.zipcode)
      boarding_house.academy = dept.academy if dept
    end
  end
end
