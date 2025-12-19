# frozen_string_literal: true

FactoryBot.define do
  factory :multi_activity do
    title { 'Observation de différents métiers' }
    description do
      "Nous proposons un stage d'une semaine pour les élèves de 3ème, " \
      "qui se déroulera du lundi au vendredi. Voici le planning prévu :\n" \
      "Lundi : Découverte de Bouygues, où les stagiaires apprendront les bases " \
      "de la construction et des projets d'infrastructure.\n" \
      "Mardi : Visite chez Darty, avec une immersion dans le service client " \
      "et la vente de produits électroniques."
    end
    association :employer, factory: :employer
  end
end

