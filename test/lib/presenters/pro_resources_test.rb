# frozen_string_literal: true

require "test_helper"

module Presenters
  class ProResourcesTest < ActiveSupport::TestCase
    # Mirrors the Prismic documents tagged 'pro', grouped by category
    # in the order returned by PagesController#serialize_resource.
    def prismic_resources
      {
        "Documentation API" => [
          { url: "https://github.com/betagouv/monstagedeseconde/tree/review/doc/api/v2",
            title: "Documentation API", kind: :url }
        ],
        "Convention" => [
          { url: "https://prismic.io/convention.pdf",
            title: "Convention relative à l'organisation de la séquence d'observation", kind: :file }
        ],
        "Ressources" => [
          { url: "https://prismic.io/memo-hcr.pdf", title: "Mémo entreprises de la branche HCR", kind: :file },
          { url: "https://docs.numerique.gouv.fr/docs/xxx/",
            title: "Tutoriel 1 élève 1 stage à l'usage des offreurs", kind: :url },
          { url: "https://prismic.io/presentation.pdf", title: "Présentation du dispositif", kind: :file },
          { url: "https://docs.numerique.gouv.fr/docs/yyy/",
            title: "FAQ - utilisation de la plateforme", kind: :url },
          { url: "https://prismic.io/stagiaires.pdf", title: "Préparer lʼarrivée de vos stagiaires", kind: :file },
          { url: "https://nuage06.apps.education.fr/index.php/s/NP49mPGfQ8Ddmei",
            title: "Comment déposer une offre de stage ?", kind: :url },
          { url: "https://prismic.io/livret-aft.pdf",
            title: "Livret d’accueil pour les stages de 2de générale et technologique par l'AFT", kind: :file }
        ],
        "Circulaire" => [
          { url: "https://www.education.gouv.fr/bo/2025/Hebdo47/MENE2517062C",
            title: "Circulaire du 21 novembre 2025", kind: :url }
        ]
      }
    end

    test "#to_a hides documents superseded by hardcoded cards" do
      titles = ProResources.new(prismic_resources).to_a.map { |document| document[:title] }

      assert_not_includes titles, "Tutoriel 1 élève 1 stage à l'usage des offreurs"
      assert_not_includes titles, "FAQ - utilisation de la plateforme"
      assert_not_includes titles, "Comment déposer une offre de stage ?"
    end

    test "#to_a orders documents as requested in MGF-1782" do
      expected_titles = [
        "Convention relative à l'organisation de la séquence d'observation",
        "Circulaire du 21 novembre 2025",
        "Présentation du dispositif",
        "Préparer lʼarrivée de vos stagiaires",
        "Mémo entreprises de la branche HCR",
        "Livret d’accueil pour les stages de 2de générale et technologique par l'AFT",
        "Documentation API"
      ]

      assert_equal expected_titles, ProResources.new(prismic_resources).to_a.map { |document| document[:title] }
    end

    test "#to_a places unknown documents before the API documentation" do
      resources = prismic_resources
      resources["Ressources"] << { url: "https://prismic.io/new.pdf", title: "Nouveau document", kind: :file }
      titles = ProResources.new(resources).to_a.map { |document| document[:title] }

      assert_equal "Nouveau document", titles[-2]
      assert_equal "Documentation API", titles[-1]
    end

    test "#to_a is empty when Prismic is unavailable" do
      assert_empty ProResources.new([]).to_a
      assert_empty ProResources.new(nil).to_a
    end
  end
end
