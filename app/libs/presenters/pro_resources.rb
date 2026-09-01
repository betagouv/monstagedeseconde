# frozen_string_literal: true

module Presenters
  # Curates the Prismic resources shown on the /professionnels landing page:
  # hides documents superseded by the hardcoded FAQ card or removed from the
  # page (tutorial videos, MGF-1782) and enforces
  # the display order requested in MGF-1782 (Prismic has no rank field).
  class ProResources
    HIDDEN_TITLES = [
      /tutoriel/i,
      /faq/i,
      /comment déposer/i
    ].freeze

    TITLES_ORDER = [
      /convention/i,
      /circulaire/i,
      /présentation/i,
      /préparer/i,
      /mémo/i,
      /livret/i
    ].freeze

    API_DOC_TITLE = /documentation api/i

    def initialize(resources)
      @resources = resources
    end

    def to_a
      documents = @resources.respond_to?(:values) ? @resources.values.flatten : []
      documents.reject { |document| HIDDEN_TITLES.any? { |pattern| document[:title]&.match?(pattern) } }
               .sort_by.with_index { |document, index| [ rank(document[:title]), index ] }
    end

    private

    def rank(title)
      return TITLES_ORDER.size + 1 if title&.match?(API_DOC_TITLE)

      TITLES_ORDER.index { |pattern| title&.match?(pattern) } || TITLES_ORDER.size
    end
  end
end
