# frozen_string_literal: true

require 'test_helper'

class CodedCraftTest < ActiveSupport::TestCase
  test 'autocomplete_by_name find stuffs upper or lower case' do
    coded_craft = create(:coded_craft, name: 'conducteur de travaux')
    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'CONDUCTEUR').size, 'find with uppercase fails'
    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'conducteur').size, 'find with lowercase fails'
  end

  test 'autocomplete_by_name find with or without accent' do
    coded_craft = create(:coded_craft, name: "chef d'établissement")
    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'établissement').size, 'find with accent'
    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'etablissement').size, 'find without accent'
  end

  test 'pg_search_highlight_*' do
    coded_craft = create(:coded_craft, name: 'conducteur de travaux')
    keyword = 'conducteur'

    search_by_name_result = Api::CodedCraft.autocomplete_by_name(term: keyword).first
    assert_equal "<b>#{keyword}</b> de travaux", search_by_name_result.pg_search_highlight_name
  end

  test 'autocomplete_by_name find compound craft names' do
    coded_craft = create(:coded_craft, name: 'conducteur de travaux')

    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'Cond').size, 'coumpound with missing letters missed'
    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'conducteur').size,
                 'compound with single complete word missed'
    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'trav').size,
                 'compound halfly spelled with dashes missed'
    assert_equal 1, Api::CodedCraft.autocomplete_by_name(term: 'travaux').size,
                 'compound fully spelled with dashes missed'
  end

  test 'autocomplete_by_name returns ordered result (by Levenshtein distance on city.name)' do
    coded_craft_0 = create(:coded_craft, name: 'conducteur de travaux')
    coded_craft_1 = create(:coded_craft, name: 'conductrice de train')
    coded_craft_2 = create(:coded_craft, name: 'convoyeur de matériel')

    results = Api::CodedCraft.autocomplete_by_name(term: 'Condu')

    assert_equal coded_craft_0.name, results[0].name
    assert_equal coded_craft_1.name, results[1].name
    assert_nil results[2]&.name
  end

  test 'autocomplete_by_name return pg_search_highlight' do
    coded_craft = create(:coded_craft, name: 'conducteur de travaux')
    coded_craft = create(:coded_craft, name: 'conducteur de travaux informatiques')
    results = Api::CodedCraft.autocomplete_by_name(term: 'cond')
    assert '<b>conducteur</b> de travaux', results[0].attributes['pg_search_highlight']
    assert '<b>conducteur</b> de travaux informatiques', results[1].attributes['pg_search_highlight']
  end

  test 'autocomplete_by_name find by increment, even with stop words' do
    keyword = 'conducteur'
    full_name = 'conducteur de travaux'
    create(:coded_craft, name: full_name)
    keyword.split('').each.with_index do |_, idx|
      next if idx <= 2

      query_part = keyword[0..idx]
      results = Api::CodedCraft.autocomplete_by_name(term: query_part)
      assert_equal 1, results.size, "fail to find with '#{query_part}'"
      assert_equal full_name, results[0].name
    end
  end
end
