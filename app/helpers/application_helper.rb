# frozen_string_literal: true

module ApplicationHelper
  def env_class_name
    return "development" if Rails.env.development?
    return "review" if Rails.env.staging? || Rails.env.review?
    return "staging" if request.host.include?("recette")

    ""
  end

  def helpdesk_url
    "https://uneleveunstage.crisp.help/fr/"
  end

  # not used
  # def custom_dashboard_controller?(user:)
  #   user.custom_dashboard_paths
  #       .map { |path| current_page?(path) }
  #       .any?
  # end

  # Le lien "Contactez-nous" (formulaire de contact) ne cible que les offreurs,
  # personnels pédagogiques et référents
  def display_footer_contact_link?
    return true if user_signed_in? && !current_user.student?

    [
      pro_login_path,
      school_management_login_path,
      statistician_login_path,
      new_user_session_path
    ].any? { |path| current_page?(path) }
  end

  def account_controller?(user:)
    [
      current_page?(account_path),
      current_page?(account_path(section: :resume)),
      current_page?(account_path(section: :api)),
      current_page?(account_path(section: :school))
    ].any?
  end

  def body_class_name
    class_names = []
    class_names.push("homepage fr-px-0") if homepage?
    class_names.join(" ")
  end

  def homepage?
    current_page?(root_path)
  end

  # def in_dashboard?
  #   request.path.include?('dashboard') || request.path.include?('tableau-de-bord')
  # end

  def statistics?
    controller.class.name.deconstantize == "Reporting"
  end

  def current_controller?(controller_name)
    controller.controller_name.to_s == controller_name.to_s
  end

  def page_title
    if content_for?(:page_title)
      content_for :page_title
    else
      default = "1Élève1Stage"
      i18n_key = "#{controller_path.tr('/', '.')}.#{action_name}.page_title"
      dyn_page_name = t(i18n_key, default: default)
      dyn_page_name == default ? default : "#{dyn_page_name} | #{default}"
    end
  end

  # Helper method to generate breadcrumb links
  def generate_breadcrumb_links(*links)
    links.map do |link|
      if link.is_a?(Array)
        { path: link[0], name: link[1] }
      else
        { path: "", name: link }
      end
    end
  end

  def prismic_structured_text_to_html(prismic_fragment)
    return "" if prismic_fragment.blank? || prismic_fragment.blocks.blank?

    html_parts = []
    current_list_items = []
    current_list_ordered = nil

    prismic_fragment.blocks.each do |block|
      case block
      when Prismic::Fragments::StructuredText::Block::Paragraph
        # Fermer la liste en cours si elle existe
        if current_list_items.any?
          html_parts << build_list_html(current_list_items, current_list_ordered)
          current_list_items = []
          current_list_ordered = nil
        end

        # Ajouter le paragraphe avec traitement des spans (liens)
        html_parts << content_tag(:p, process_text_with_spans(block.text, block.spans)) unless block.text.blank?

      when Prismic::Fragments::StructuredText::Block::ListItem
        # Démarrer une nouvelle liste ou continuer la liste en cours
        if current_list_items.empty?
          current_list_ordered = block.ordered
        elsif current_list_ordered != block.ordered
          # Si le type de liste change, fermer la précédente et en démarrer une nouvelle
          html_parts << build_list_html(current_list_items, current_list_ordered)
          current_list_items = []
          current_list_ordered = block.ordered
        end

        # Traiter le texte avec les spans (liens) pour les éléments de liste
        processed_text = process_text_with_spans(block.text, block.spans)
        current_list_items << processed_text unless block.text.blank?
      end
    end

    # Fermer la dernière liste si elle existe
    html_parts << build_list_html(current_list_items, current_list_ordered) if current_list_items.any?

    safe_join(html_parts, "\n")
  end

  def js_email_pattern = '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$'

  private

  # Renders the inline spans (links, strong, em) of a Prismic text block as escaped HTML.
  # Mirrors the nesting logic of Prismic::Fragments::StructuredText::Block::Text#as_html:
  # a stack of open spans, the widest spans being opened first at a given position.
  def process_text_with_spans(text, spans)
    spans = Array(spans).select { |span| span.start >= 0 && span.start < span.end && span.end <= text.length }
    return h(text) if spans.empty?

    opens = spans.group_by(&:start).transform_values { |group| group.sort_by { |span| -(span.end - span.start) } }
    closes = spans.group_by(&:end)
    boundaries = ([ 0, text.length ] + opens.keys + closes.keys).uniq.sort

    result = "".html_safe
    stack = []
    current = -> { stack.empty? ? result : stack.last[:html] }
    close_span = lambda do
      closed = stack.pop
      current.call << wrap_span(closed[:span], closed[:html])
    end

    boundaries.each_cons(2) do |from, to|
      closes.fetch(from, []).each { close_span.call }
      opens.fetch(from, []).each { |span| stack << { span: span, html: "".html_safe } }
      current.call << h(text[from...to])
    end
    closes.fetch(text.length, []).each { close_span.call }

    result
  end

  def wrap_span(span, inner)
    case span
    when Prismic::Fragments::StructuredText::Span::Hyperlink
      link_tag(span.link, inner)
    when Prismic::Fragments::StructuredText::Span::Strong
      content_tag(:strong, inner)
    when Prismic::Fragments::StructuredText::Span::Em
      content_tag(:em, inner)
    else
      inner
    end
  end

  def link_tag(link, inner)
    case link
    when Prismic::Fragments::WebLink
      target = link.target.presence
      content_tag(:a, inner, href: link.url.to_s, target: target, rel: (target == "_blank" ? "noopener noreferrer" : nil))
    when Prismic::Fragments::DocumentLink
      content_tag(:a, inner, href: link.url.to_s)
    else
      inner
    end
  end

  def build_list_html(list_items, ordered)
    return "".html_safe if list_items.empty?

    tag = ordered ? "ol" : "ul"
    items_html = safe_join(list_items.map { |item| content_tag(:li, item) }, "\n")
    content_tag(tag, "\n#{items_html}\n".html_safe)
  end
end
