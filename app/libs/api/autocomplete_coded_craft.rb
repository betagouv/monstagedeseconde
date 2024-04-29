# frozen_string_literal: true

module Api
  class AutocompleteCodedCraft
    MAX_LIMIT = 12
    def response_wrapper
      {
        match_by_name: [],
        no_match: result.size.zero?
      }
    end

    def as_json(_options = {})
      result.each_with_object(response_wrapper) do |coded_craft, accu|
        # if coded_craft.match_by_name?(term)
        accu[:match_by_name] = append_result(
          list: accu["n#{coded_craft.ogr_code}".to_sym],
          item: coded_craft,
          sort_by: :name
        )
        # else
        #   accu[:match_by_name] = append_result(list: accu[:match_by_name],
        #                                        item: coded_craft,
        #                                        sort_by: :name)
        # end
      end
    end

    private

    attr_reader :term, :limit, :result
    def initialize(term:, limit: MAX_LIMIT)
      @term = term
      @limit = limit
      @result = Api::CodedCraft.autocomplete_by_name(term: term)
                               .limit(limit)
    end

    def append_result(list:, item:, sort_by:)
      # Following sort by puts at the end those with 
      # attribute nil that would otherwise generate an error
      Array(list).push(item)
                 .sort_by do |ite| 
                    [ite.send(sort_by) ? 0 : 1 , ite.send(sort_by)]
                 end
    end
  end
end
