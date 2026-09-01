require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  ST = Prismic::Fragments::StructuredText

  def structured_text(*blocks)
    ST.new(blocks)
  end

  def paragraph(text, *spans)
    ST::Block::Paragraph.new(text, spans)
  end

  # Offsets of +part+ inside +text+, as Prismic spans expect them.
  def range(text, part)
    start = text.index(part)
    [ start, start + part.length ]
  end

  def strong(text, part) = ST::Span::Strong.new(*range(text, part))
  def em(text, part) = ST::Span::Em.new(*range(text, part))
  def link(text, part, url, target = nil) = ST::Span::Hyperlink.new(*range(text, part), Prismic::Fragments::WebLink.new(url, target))

  test 'prismic_structured_text_to_html returns an empty string for a blank fragment' do
    assert_equal '', view.prismic_structured_text_to_html(nil)
    assert_equal '', view.prismic_structured_text_to_html(structured_text)
  end

  test 'prismic_structured_text_to_html renders a paragraph with a strong span (top banner case)' do
    text = 'Il sera possible aux élèves de se connecter à partir de lundi 21 septembre 2026.'
    fragment = structured_text(paragraph(text, strong(text, 'lundi 21 septembre 2026')))

    html = view.prismic_structured_text_to_html(fragment)

    assert_predicate html, :html_safe?
    assert_equal '<p>Il sera possible aux élèves de se connecter à partir de ' \
                 '<strong>lundi 21 septembre 2026</strong>.</p>', html
  end

  test 'prismic_structured_text_to_html renders em spans' do
    text = 'Un mot important'

    assert_equal '<p>Un mot <em>important</em></p>',
                 view.prismic_structured_text_to_html(structured_text(paragraph(text, em(text, 'important'))))
  end

  test 'prismic_structured_text_to_html renders adjacent spans' do
    text = 'gras puis italique'
    fragment = structured_text(paragraph(text, strong(text, 'gras'), em(text, 'italique')))

    assert_equal '<p><strong>gras</strong> puis <em>italique</em></p>', view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html joins several paragraphs' do
    fragment = structured_text(paragraph('Premier'), paragraph('Second'))

    assert_equal "<p>Premier</p>\n<p>Second</p>", view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html renders hyperlinks with escaped attributes' do
    text = 'Voir le site'
    fragment = structured_text(paragraph(text, link(text, 'site', 'https://example.org/?a=1&b=2', '_blank')))

    assert_equal '<p>Voir le <a href="https://example.org/?a=1&amp;b=2" target="_blank" ' \
                 'rel="noopener noreferrer">site</a></p>', view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html nests a link inside a strong span' do
    text = 'Consultez le site'
    fragment = structured_text(paragraph(text, strong(text, text), link(text, 'le site', 'https://example.org')))

    assert_equal '<p><strong>Consultez <a href="https://example.org">le site</a></strong></p>',
                 view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html nests a strong span inside a link' do
    text = 'Consultez le site'
    fragment = structured_text(paragraph(text, link(text, text, 'https://example.org'), strong(text, 'le site')))

    assert_equal '<p><a href="https://example.org">Consultez <strong>le site</strong></a></p>',
                 view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html closes crossing spans in LIFO order like the Prismic gem' do
    text = 'abcdef'
    fragment = structured_text(paragraph(text, ST::Span::Strong.new(0, 4), ST::Span::Em.new(2, 6)))

    assert_equal '<p><strong>ab<em>cd</em>ef</strong></p>', view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html ignores label and degenerate spans' do
    text = 'Texte sans style'
    fragment = structured_text(
      paragraph(text, ST::Span::Label.new(*range(text, 'sans'), 'highlight'), ST::Span::Strong.new(3, 3))
    )

    assert_equal '<p>Texte sans style</p>', view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html renders list items as a list' do
    fragment = structured_text(
      paragraph('Intro'),
      ST::Block::ListItem.new('Un', [], false),
      ST::Block::ListItem.new('Deux', [], false)
    )

    assert_equal "<p>Intro</p>\n<ul>\n<li>Un</li>\n<li>Deux</li>\n</ul>", view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html escapes html injected in the CMS content' do
    fragment = structured_text(paragraph('<script>alert(1)</script>'))

    assert_equal '<p>&lt;script&gt;alert(1)&lt;/script&gt;</p>', view.prismic_structured_text_to_html(fragment)
  end

  test 'prismic_structured_text_to_html escapes html inside spans' do
    text = 'Tom & <Jerry>'
    fragment = structured_text(paragraph(text, strong(text, '<Jerry>')))

    assert_equal '<p>Tom &amp; <strong>&lt;Jerry&gt;</strong></p>', view.prismic_structured_text_to_html(fragment)
  end
end
