# frozen_string_literal: true

module ApplicationHelper
  def env_class_name
    return 'development' if Rails.env.development?
    return 'review' if Rails.env.staging? || Rails.env.review?
    return 'staging' if request.host.include?('recette')

    ''
  end

  def helpdesk_url
    'https://uneleveunstage.crisp.help/fr/'
  end

  def custom_dashboard_controller?(user:)
    user.custom_dashboard_paths
        .map { |path| current_page?(path) }
        .any?
  end

  def account_controller?(user:)
    [
      current_page?(account_path),
      current_page?(account_path(section: :resume)),
      current_page?(account_path(section: :api)),
      current_page?(account_path(section: :identity)),
      current_page?(account_path(section: :school))
    ].any?
  end

  def onboarding_flow?
    devise_controller? && request.path.include?('identity_id')
  end

  def body_class_name
    class_names = []
    class_names.push('homepage fr-px-0') if homepage?
    class_names.push('onboarding-flow') if onboarding_flow?
    class_names.join(' ')
  end

  def homepage?
    current_page?(root_path)
  end

  # def in_dashboard?
  #   request.path.include?('dashboard') || request.path.include?('tableau-de-bord')
  # end

  def statistics?
    controller.class.name.deconstantize == 'Reporting'
  end

  def current_controller?(controller_name)
    controller.controller_name.to_s == controller_name.to_s
  end

  def page_title
    if content_for?(:page_title)
      content_for :page_title
    else
      default = '1Élève1Stage'
      i18n_key = "#{controller_path.tr('/', '.')}.#{action_name}.page_title"
      dyn_page_name = t(i18n_key, default: default)
      dyn_page_name == default ? default : "#{dyn_page_name} | #{default}"
    end
  end

  def regions_list
    [
      { name: 'Myfuture',
        url: 'https://myfutu.re/',
        logo: 'logo-myfuture.png',
        alt: 'logo de Myfuture' },
      { name: 'MEDEF',
        url: 'https://www.medef.com/fr/',
        logo: 'logo-medef.png',
        alt: 'logo du MEDEF' },
      { name: 'Decathlon',
        url: 'https://www.decathlon.fr/',
        logo: 'logo-decathlon.png',
        alt: 'logo de Décathlon' },
      { name: 'Destination Métier',
        url: 'https://www.destination-metier.fr/',
        logo: 'logo-destination-metier.png',
        alt: 'logo de Destination Métier' },
      { name: 'Femmes@Numérique',
        url: 'https://www.femmes-numerique.fr/',
        logo: 'logo-femmes-numerique.png',
        alt: 'logo de Femmes Numérique' },
      { name: 'France Travail ',
        url: 'https://www.france-travail.fr/',
        logo: 'logo-france-travail.png',
        alt: 'logo de France Travail' },
      { name: 'Arpejeh',
        url: 'https://www.arpejeh.com/',
        logo: 'logo-arpejeh.png',
        alt: 'logo de Arpejeh' },
      { name: 'UIMM Savoie',
        url: 'https://ui-savoie.com/',
        logo: 'logo-uimm-savoie.png',
        alt: 'logo de UIMM Savoie' },
      { name: 'OPCO EP',
        url: 'https://www.opcoep.fr/',
        logo: 'logo-opco-ep.png',
        alt: 'logo de OPCO EP' },
      { name: 'ONISEP',
        url: 'https://www.onisep.fr/',
        logo: 'logo-onisep.png',
        alt: 'logo de ONISEP' },
      { name: 'OPCO 2i',
        url: 'https://www.opco2i.fr/',
        logo: 'logo-opco-2i.png',
        alt: 'logo de OPCO 2i' },
      { name: 'Université des Métiers du Nucléaire',
        url: 'https://www.monavenirdanslenucleaire.fr/',
        logo: 'logo-univ-metiers-nucleaire.png',
        alt: 'logo de l\'Université des métiers du nucléaire' }
    ]
  end

  def involved_partners_logos
    [
      { logo_img: 'airfrance.png', alt: 'airfrance logo' },
      { logo_img: 'bnp.png', alt: 'bnp logo' },
      { logo_img: 'bonduelle.png', alt: 'bonduelle logo' },
      { logo_img: 'bpce.png', alt: 'bpce logo' },
      { logo_img: 'ch-cornouille.png', alt: 'ch-cornouille logo' },
      { logo_img: 'campus-bretagne.png', alt: 'campus bretagne logo' },
      { logo_img: 'ca.png', alt: 'CA logo' },
      { logo_img: 'finances-publiques.png', alt: 'finances publiques logo' },
      { logo_img: 'gendarmerie.png', alt: 'gendarmerie logo' },
      { logo_img: 'laposte.png', alt: 'laposte logo' },
      { logo_img: 'min-interieur.png', alt: 'min interieur logo' },
      { logo_img: 'normandie-manutention.png', alt: 'normandie manutention logo' },
      { logo_img: 'orchestre.png', alt: 'orchestre national logo' },
      { logo_img: 'orchestre-euro.png', alt: 'orchestre europeen logo' },
      { logo_img: 'police.png', alt: 'police logo' },
      { logo_img: 'renault.png', alt: 'renault logo' },
      { logo_img: 'rte.png', alt: 'rte logo' },
      { logo_img: 'safran.png', alt: 'safran logo' },
      { logo_img: 'saint-gobain.png', alt: 'saint gobain logo' },
      { logo_img: 'sogetrel.png', alt: 'sogetrel logo' },
      { logo_img: 'suez.png', alt: 'suez logo' },
      { logo_img: 'thales.png', alt: 'thales logo' },
      { logo_img: 'mairie-toulouse.png', alt: 'mairie toulouse logo' },
      { logo_img: 'univ-rennes.png', alt: 'univ rennes logo' }
    ]
  end

  # Helper method to generate breadcrumb links
  def generate_breadcrumb_links(*links)
    links.map do |link|
      if link.is_a?(Array)
        { path: link[0], name: link[1] }
      else
        { path: '', name: link }
      end
    end
  end

  def prismic_structured_text_to_html(prismic_fragment)
    return '' if prismic_fragment.blank? || prismic_fragment.blocks.blank?

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
        html_parts << "<p>#{process_text_with_spans(block.text, block.spans)}</p>" unless block.text.blank?

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

    html_parts.join("\n").html_safe
  end

  private

  def process_text_with_spans(text, spans)
    return text if spans.blank?

    # Trier les spans par position de début
    sorted_spans = spans.sort_by(&:start)

    # Construire le HTML avec les liens
    result = ''
    last_end = 0

    sorted_spans.each do |span|
      # Ajouter le texte avant le span
      result += text[last_end...span.start] if span.start > last_end

      # Traiter le span selon son type
      case span
      when Prismic::Fragments::StructuredText::Span::Hyperlink
        link_text = text[span.start...span.end]
        link_attributes = build_link_attributes(span.link)
        result += "<a #{link_attributes}>#{link_text}</a>"
      else
        # Pour les autres types de spans, ajouter le texte tel quel
        result += text[span.start...span.end]
      end

      last_end = span.end
    end

    # Ajouter le texte restant après le dernier span
    result += text[last_end..-1] if last_end < text.length

    result
  end

  def build_link_attributes(link)
    attributes = []

    case link
    when Prismic::Fragments::WebLink
      # S'assurer que l'URL est correctement échappée
      safe_url = h(link.url.to_s)
      attributes << "href=\"#{safe_url}\""
      attributes << "target=\"#{link.target}\"" if link.target.present?
      attributes << 'rel="noopener noreferrer"' if link.target == '_blank'
    when Prismic::Fragments::DocumentLink
      # Pour les liens internes vers d'autres documents Prismic
      safe_url = h(link.url.to_s)
      attributes << "href=\"#{safe_url}\""
    end

    attributes.join(' ')
  end

  def build_list_html(list_items, ordered)
    return '' if list_items.empty?

    tag = ordered ? 'ol' : 'ul'
    items_html = list_items.map { |item| "<li>#{item}</li>" }.join("\n")

    "<#{tag}>\n#{items_html}\n</#{tag}>"
  end
end
