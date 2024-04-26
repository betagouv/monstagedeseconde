# frozen_string_literal: true

module Api
  class CodedCraft < ApplicationRecord
    include PgSearch::Model
    MAX_RESULTS_LIMIT = 18
    MIN_RESULTS_LIMIT = 8

    pg_search_scope :search_by_name,
                    against: :name,
                    ignoring: :accents,
                    using: {
                      tsearch: {
                        dictionary: 'public.fr',
                        tsvector_column: 'search_tsv',
                        prefix: true
                      }
                    }

    scope :autocomplete_by_name, lambda { |term:, limit: MIN_RESULTS_LIMIT|
      search_by_name(term)
        .highlight_by_name(term)
        .select("#{table_name}.*")
        .limit([MIN_RESULTS_LIMIT, limit.to_i, MAX_RESULTS_LIMIT].sort.second)
    }

    scope :visible, -> { where(visible: true) }

    # Rails_admin supposedly requires following two methods
    def autocomplete; end
    def autocomplete=(val); end

    def as_json(options = {})
      super
    end

    # private

    # autocomplete search by %i[name city]
    # following scopes declare one scope per autocomplete column
    # use PgSearch highlight feature to show matching part of columns
    #
      # private scope only used for select
    pg_search_scope :search_name,
                    against: :name,
                    ignoring: :accents,
                    using: {
                      tsearch: {
                        dictionary: 'public.fr',
                        highlight: {
                          StartSel: '<b>',
                          StopSel: '</b>'
                        }
                      }
                    }

    # make a SQL select with ts_headline (highlight part of full text search match)
    # we use previously defined pg_search_scope in order to build the right ts_headline pg call
    # see: https://www.postgresql.org/docs/current/textsearch-controls.html
    scope :highlight_by_name, lambda { |term|
      current_pg_search_scope = search_name(term)
      select("#{current_pg_search_scope.tsearch.highlight.to_sql} as pg_search_highlight_name")
    }

    def match_by_name?(term)
      current_pg_highlight_attribute_value = attributes["pg_search_highlight_name"]

      %r{<b>.*</b>}.match?(current_pg_highlight_attribute_value) ||
        name.downcase.include?(term.downcase)
    end

    # read SQL result of ts_headline (highlight_by_name) pg_search_highlight_name
    def pg_search_highlight_name
      # return nil unless send(:"match_by_name?", self.send(highlight_column))
      attributes["pg_search_highlight_name"]
    end
  end
end
