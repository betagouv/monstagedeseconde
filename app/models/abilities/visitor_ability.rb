# frozen_string_literal: true

module Abilities
  module VisitorAbility
    def visitor_abilities
      can %i[read apply], InternshipOffer
      can(:read_employer_name, InternshipOffer) do |internship_offer|
        read_employer_name?(internship_offer:)
      end
      can :share, InternshipOffer
    end
  end
end
