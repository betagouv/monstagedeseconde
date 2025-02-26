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
      default = '1Elève1Stage'
      i18n_key = "#{controller_path.tr('/', '.')}.#{action_name}.page_title"
      dyn_page_name = t(i18n_key, default: default)
      dyn_page_name == default ? default : "#{dyn_page_name} | #{default}"
    end
  end

  def regions_list
    [
      { name: 'Myfuture',
        url: 'https://www.myfuture.fr/',
        logo: 'logo-myfuture.png',
        alt: 'logo de Myfuture' },
      { name: 'MEDEF',
        url: 'https://www.medef.com/fr/',
        logo: 'logo-medef.png',
        alt: 'logo du MEDEF' },
      { name: 'Décathlon',
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
      { name: 'Bretagne',
        url: 'https://www.bretagne.bzh/',
        logo: 'bretagne.png',
        alt: 'logo de Bretagne' },
      { name: 'UIMM Savoie',
        url: 'https://ui-savoie.com/',
        logo: 'logo-uimm-savoie.png',
        alt: 'logo de UIMM Savoie' },
      { name: 'OPCO EP',
        url: 'https://www.opcoep.fr/',
        logo: 'logo-opco-ep.png',
        alt: 'logo de OPCO EP' }
    ]
  end

  def involved_partners_logos
    [
      { logo_img: 'airfrance.png', alt: 'airfrance logo' },
      { logo_img: 'bonduelle.png', alt: 'bonduelle logo' },
      { logo_img: 'bnp.png', alt: 'bnp logo' },
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
end
