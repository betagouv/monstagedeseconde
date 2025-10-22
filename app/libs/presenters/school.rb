module Presenters
  class School
    def select_text_method
      "#{school_name} - #{school.city} - #{school.zipcode}"
    end
    alias agreement_address select_text_method

    def school_name
      return school.name if start_with_lycee_or_college?
      return "Collège #{school.name}" if school.college?

      "Lycée #{school.name}"
    end

    def school_name_in_sentence
      return school.name if school.name.match(/^\s*Lycée.*/)

      "lycée #{school.name}"
    end

    def address
      if school.street.nil?
        "#{'.' * 100}, #{school.zipcode} #{school.city}"
      else
        "#{school.street}, #{school.zipcode} #{school.city}"
      end
    end

    def staff
      %i[teachers others].map do |role|
        school.send(role).kept.includes(:school)
      end.flatten
    end

    private

    def start_with_lycee_or_college?
      school.name.match(/^\s*(Lycée|Collège|Lycee|College).*/)
    end

    attr_accessor :school

    def initialize(school)
      @school = school
    end
  end
end
