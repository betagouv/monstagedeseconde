require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  ST = Prismic::Fragments::StructuredText

  def structured_text(*blocks)
    ST.new(blocks)
  end

  test 'prismic_structured_text_to_html returns an empty string for a blank fragment' do
    assert_equal '', view.prismic_structured_text_to_html(nil)
    assert_equal '', view.prismic_structured_text_to_html(structured_text)
  end

  test 'prismic_structured_text_to_html renders a paragraph with a strong span (top banner case)' do
    text = 'Il sera possible aux élèves de se connecter à partir de lundi 21 septembre 2026.'
    fragment = structured_text(ST::Block::Paragraph.new(text, [ ST::Span::Strong.new(50, 78) ]))

    html = view.prismic_structured_text_to_html(fragment)

    assert_predicate html, :html_safe?
    assert_equal "<p>#{text}</p>", html
  end

  test 'prismic_structured_text_to_html joins several paragraphs' do
    fragment = structured_text(
      ST::Block::Paragraph.new('Premier', []),
      ST::Block::Paragraph.new('Second', [])
    )

    assert_equal "<p>Premier</p>\n<p>Second</p>", view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html renders hyperlinks with escaped attributes' do
    link = Prismic::Fragments::WebLink.new('https://example.org/?a=1&b=2', '_blank')
    fragment = structured_text(
      ST::Block::Paragraph.new('Voir le site', [ ST::Span::Hyperlink.new(8, 12, link) ])
    )

    html = view.prismic_structured_text_to_html(fragment)

    assert_equal '<p>Voir le <a href="https://example.org/?a=1&amp;b=2" target="_blank" ' \
                 'rel="noopener noreferrer">site</a></p>', html
  end

  test 'prismic_structured_text_to_html renders list items as a list' do
    fragment = structured_text(
      ST::Block::Paragraph.new('Intro', []),
      ST::Block::ListItem.new('Un', [], false),
      ST::Block::ListItem.new('Deux', [], false)
    )

    assert_equal "<p>Intro</p>\n<ul>\n<li>Un</li>\n<li>Deux</li>\n</ul>", view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html escapes html injected in the CMS content' do
    fragment = structured_text(ST::Block::Paragraph.new('<script>alert(1)</script>', []))

    assert_equal '<p>&lt;script&gt;alert(1)&lt;/script&gt;</p>', view.prismic_structured_text_to_html(fragment)
  end
end
