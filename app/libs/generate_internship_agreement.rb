require 'cgi'
require 'open-uri'
include ApplicationHelper

class GenerateInternshipAgreement < Prawn::Document
  def initialize(internship_agreement_id)
    @internship_agreement = InternshipAgreement.find(internship_agreement_id)
    @pdf = Prawn::Document.new(margin: [40, 40, 90, 40])
    @pdf.font_families.update('Arial' => {
                                normal: Rails.root.join('public/assets/fonts/arial.ttf').to_s,
                                bold: Rails.root.join('public/assets/fonts/arial_bold.ttf').to_s,
                                italic: Rails.root.join('public/assets/fonts/arial_italic.ttf').to_s
                              })
    @pdf.font 'Arial'
  end

  PAGE_WIDTH = 532
  SIGNATURE_OPTIONS = {
    position: :center,
    vposition: :center,
    fit: [PAGE_WIDTH / 4, PAGE_WIDTH / 4]
  }

  def call
    header
    title
    intro
    contractors

    article_1
    article_2
    article_3
    article_4
    article_5
    article_6
    article_7
    article_8
    article_9
    article_bonus

    annexe_a
    annexe_b

    signatures

    footer
    page_number
    @pdf
  end

  def header
    y_position = @pdf.cursor
  end

  def title
    title = "Convention relative à l'organisation de la séquence d'observation en milieu "\
            'professionnel pour les élèves de collège (quatrième et troisième) et de lycée '\
            '(seconde générale et technologique)'
    @pdf.text title, size: 16, align: :left, color: '10008F'
    @pdf.move_down 15
  end

  def intro
    #  set size to 10
    @pdf.font_size 9
    paraphing(
      'Vu le Code du travail, et notamment son article L. 4153-1 ; ' \
      'le Code de l\'éducation, et notamment ses articles L. 124-1, L. 134-9, ' \
      'L. 313-1, L. 331-4, L. 331-5, L. 332-3, L. 335-2, L. 411-3, L. 421-7, ' \
      'L. 911-4, D. 331-1 à D. 331-9, D. 333-3-1 ; ' \
      'le Code civil, et notamment ses articles 1240 à 1242 ; ' \
      'la circulaire n°96-248 du 25-10-1996 relative à la surveillance des élèves ; ' \
      'la circulaire du 10-2-2021 relative au projet d\'accueil individualisé pour raison de santé ; ' \
      'la circulaire du 13-6-2023 relative à l\'organisation des sorties et voyages scolaires ' \
      'dans les écoles, les collèges et les lycées publics ; ' \
      'la circulaire du 12 juillet 2024 relative aux séquences d\'observation, ' \
      'visites d\'information et stages pour les élèves de collège ; ' \
      "la délibération du conseil d'administration en date du #{@internship_agreement.delegation_date.strftime('%d/%m/%Y')};"
    )
    @pdf.move_down 5
  end

  def contractors
    label_form('Entre')
    paraphing("L'entreprise ou l'organisme d'accueil "\
      "#{@internship_agreement.employer_name}, représentée par M/Mme "\
      "#{@internship_agreement.organisation_representative_full_name} ("\
      "#{@internship_agreement.employer_contact_email}), en qualité "\
      "de responsable de l'organisme d'accueil\n" \
      "SIRET : #{@internship_agreement.siret}\n" \
      "Adresse du siège social : #{@internship_agreement.entreprise_address}")

    paraphing("d'une part, et \n "\
      "L'établissement d'enseignement scolaire : #{@internship_agreement.school.name} (code U.A.I.: #{@internship_agreement.school.code_uai}), "\
      "représenté par M/Mme #{@internship_agreement.school_representative_full_name}, "\
      "en qualité de chef(fe) d'établissement d'autre part, \n" \
      'Il a été convenu ce qui suit :')
  end

  def article_1
    titleing('Titre I : Dispositions générales')
    paraphing('Article 1 - '\
      "La présente convention a pour objet la mise en œuvre d'une séquence "\
      "d'observation en milieu professionnel, au bénéfice en classe de quatrième "\
      'ou de troisième au collège ou en classe de seconde générale et technologique au lycée.')
  end

  def article_2
    paraphing("Article 2 - Les objectifs et les modalités de la séquence d'observation sont consignés dans l'annexe pédagogique. \n"\
    'Les modalités de prise en charge des frais afférents à cette '\
    "séquence ainsi que les modalités d'assurances sont définies dans l'annexe financière.")
  end

  def article_3
    paraphing("Article 3 - L'organisation de la séquence d'observation est déterminée d'un "\
    "commun accord entre la/le responsable de l'organisme d'accueil et la/le chef(fe) d'établissement.")
  end

  def article_4
    paraphing('Article 4 - Les élèves demeurent sous statut scolaire durant la période '\
    "d'observation en milieu professionnel. Ils restent placés sous l'autorité "\
    "et la responsabilité du chef(fe) d'établissement. \n"\
    "Ils ne peuvent prétendre à aucune rémunération ou gratification de l'entreprise ou de l'organisme d'accueil.")
  end

  def article_5
    paraphing("Article 5 - Durant la séquence d'observation, les élèves n'ont pas à "\
      "concourir au travail dans l'entreprise ou l'organisme d'accueil."\
      "Au cours des séquences d'observation, les élèves peuvent effectuer des "\
      'enquêtes en liaison avec les enseignements. Ils peuvent également participer '\
      "à des activités de l'entreprise ou de l'organisme d'accueil, à des essais ou à "\
      'des démonstrations en liaison avec les enseignements et les objectifs de formation '\
      'de leur classe, sous le contrôle des personnels responsables de leur encadrement en milieu professionnel.')

    paraphing(
      "Les élèves ne peuvent accéder aux machines, appareils ou produits dont l'usage est proscrit aux mineurs par les articles D. 4153-15 à D. 4153-37 du Code du travail. Ils ne peuvent ni procéder à des manœuvres ou manipulations sur d'autres machines, produits ou appareils de production, ni effectuer des travaux légers autorisés aux mineurs par ce même code."
    )
    paraphing(
      "Si l'état de santé de l'élève nécessite d'avoir une trousse d'urgence dans le cadre d'un Projet d'Accueil Individualisé (PAI), la famille s'assure que son enfant emporte la trousse pendant la durée de la séquence d'observation."
    )
  end

  def article_6
    paraphing(
      "Article 6 - La/le responsable de l'organisme d'accueil prend les dispositions nécessaires "\
      "pour garantir sa responsabilité civile chaque fois qu'elle sera engagée (en "\
      'application des articles 1240 à 1242 du Code civil) :'
    )
    html_formating "<div style='margin-left: 25'>- soit en souscrivant une assurance particulière "\
      "garantissant sa responsabilité civile en cas de faute imputable à l'entreprise ou à "\
      "l'organisme d'accueil à l'égard de l'élève ;"

    @pdf.move_down 5
    html_formating "<div style='margin-left: 25'>- soit en ajoutant à son contrat déjà souscrit "\
      "au titre de la \“responsabilité civile entreprise\” ou de la \“responsabilité"\
      "civile professionnelle\” un avenant relatif à l'accueil d'élèves."

    @pdf.move_down 5
    paraphing(
      "La/le chef(fe) de l'établissement d'enseignement contracte une assurance couvrant la "\
      "responsabilité civile des élèves placés sous sa responsabilité pour les dommages qu'ils "\
      "pourraient causer à l’occasion de la visite d'information ou de la séquence d'observation "\
      "en milieu professionnel, ainsi qu'en dehors de l'entreprise ou de l'organisme d’accueil, ou"\
      ' sur le trajet menant, soit au lieu où se déroule la visite d’information ou la séquence '\
      'd’observation, soit au domicile.'
    )
    paraphing(
      'L’élève (et en cas de minorité ses représentants légaux) doit souscrire et produire une '\
      'attestation d’assurance couvrant sa responsabilité civile pour les dommages qu’il pourrait '\
      'causer ou qui pourraient lui advenir en milieu professionnel.'
    )
  end

  def article_7
    paraphing(
      "Article 7 - En cas d'accident survenant à l'élève, soit en milieu professionnel, soit au"\
      " cours du trajet, la/le responsable de l'organisme d’accueil alerte sans délai la/le chef(fe)"\
      ' d’établissement d’enseignement de l’élève par tout moyen mis à sa disposition et lui adresse '\
      "la déclaration d'accident dûment renseignée dans la même journée."
    )
  end

  def article_8
    paraphing(
      'Article 8 - Dans le cadre de l’obligation générale de l’employeur d’assurer la sécurité et de '\
      'protéger la santé physique et mentale des travailleurs, et conformément aux articles L. 1142-2-1 ,'\
      ' L.1153-1 et suivants du Code du travail, et à la loi n°2018-703 du 3 août 2018 renforçant la lutte '\
      'contre les violences sexistes et sexuelles, l’organisme d’accueil s’engage à préserver l’élève de toute'\
      ' forme d’agissement sexiste, de harcèlement  ou de violence sexuelle. Il prend toutes les dispositions '\
      'nécessaires en vue de prévenir les faits de harcèlement et toute forme de violence verbale ou physique à '\
      "caractère discriminatoire. \n"\
      'L’organisme d’accueil s’engage à fournir à l’élève, dès son arrivée, une information claire sur les politiques '\
      'internes en matière de lutte contre les violences sexistes et sexuelles, ainsi que sur les procédures de '\
      "signalement et de recours disponibles. \n"\
      'En cas de difficultés, l’élève peut s’adresser à plusieurs personnes ressources dans et hors de l’organisme '\
      'd’accueil : personnel de l’établissement, tuteur de l’organisme d’accueil ou personne référente désignée par '\
      'l’organisme d’accueil. »'
    )
  end

  def article_9
    paraphing("Article 9 - La présente convention est signée pour la durée d'une séquence d'observation en milieu professionnel, fixée à :")
    html_formating "<div style='margin-left: 25'>-  5 jours consécutifs ou non, pour les élèves scolarisés en collège (facultatif en quatrième, obligatoire en troisième) ;</div>"
    @pdf.move_down 5
    html_formating "<div style='margin-left: 25'>-  une (si deux lieux différents) ou deux semaines consécutives, pour les élèves scolarisés en seconde générale ou technologique durant le dernier mois de l'année scolaire.</div>"
    @pdf.move_down 10
  end

  def article_bonus
    return unless @internship_agreement.student.school.agreement_conditions_rich_text.present?

    headering('Art 10 .')
    html_formating "<div style=''>#{@internship_agreement.student.school.agreement_conditions_rich_text.body.html_safe}</div>"
    @pdf.move_down 30
  end

  def annexe_a
    titleing('Titre II : Dispositions particulières')

    headering('A - Annexe pédagogique')

    paraphing(
      "Prénom et nom de l'élève : #{student.presenter.formal_name} \n"\
      "Date de naissance : #{student.presenter.birth_date} \n"\
      "Classe : #{dotting student&.class_room&.name}"
    )

    paraphing('Existence d’un Projet d’Accueil Individualisé pour raison de santé (PAI) à prendre en compte : '\
      "#{@internship_agreement.pai_project ? 'OUI' : 'NON'}")
    paraphing('Si oui, la trousse emportée est celle : '\
      "#{@internship_agreement.pai_trousse_family ? 'De la famille' : 'De l\'établissement'}")

    @pdf.text 'Prénom, nom et coordonnées électronique et téléphonique des représentants légaux :'
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_legal_representative_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_legal_representative_email} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_legal_representative_phone} </div>"
    @pdf.move_down 5
    @pdf.text "Prénom, nom du chef(fe) d'établissement, adresse postale et électronique du lieu de scolarisation dont relève l'élève :"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_representative_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_representative_role} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_manager.try(:email)} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_representative_phone} </div>"
    @pdf.move_down 5
    @pdf.text "Statut de l'établissement scolaire : #{@internship_agreement.legal_status.try(:capitalize)}"
    @pdf.move_down 5
    @pdf.text "Prénom, nom du tuteur ou du responsable de l'accueil en milieu professionnel et sa qualité :"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.tutor_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.tutor_role} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.tutor_email} </div>"
    @pdf.move_down 5
    @pdf.text 'Prénom et nom et coordonnées électronique et téléphonique du ou (des) enseignant(s) '\
      "référent(s) chargé(s) du suivi de la séquence d'observation en milieu professionnel :"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_email} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_phone} </div>"
    @pdf.move_down 5
    paraphing_bold("Dates de la séquence d'observation en milieu professionnel :")
    @pdf.move_up 10
    paraphing("La séquence d'observation en milieu professionnel se déroule #{@internship_agreement.date_range.downcase} inclus.")

    # paraphing("Lieu de la séquence d'observation en milieu professionnel :")
    # paraphing(@internship_agreement.internship_address)
    # @pdf.move_down 15

    # Repères réglementaires relatifs à la législation sur le travail
    paraphing_bold('Repères réglementaires relatifs à la législation sur le travail :')
    @pdf.move_up 10
    paraphing("Les durées maximales de travail sont de trente-cinq heures hebdomadaires et de sept heures quotidiennes. \n"\
      "Les repos quotidiens de l’élève sont respectivement de quatorze heures consécutives au minimum et hebdomadaire de deux jours consécutifs. \n"\
    "Dès lors que le temps de travail quotidien atteint quatre heures trente minutes, l’élève doit bénéficier d’un temps de pause de trente minutes consécutives minimum. \n")

    @pdf.text "Les horaires journaliers de l'élève sont précisés ci-dessous :"
    @pdf.move_down 10

    internship_offer_hours = []
    %w[lundi mardi mercredi jeudi vendredi samedi].each_with_index do |weekday, i|
      if @internship_agreement.daily_planning?
        start_hours = @internship_agreement.daily_hours&.dig(weekday)&.first
        end_hours = @internship_agreement.daily_hours&.dig(weekday)&.last
      else
        start_hours = weekday == 'samedi' ? '' : @internship_agreement.weekly_hours&.first
        end_hours   = weekday == 'samedi' ? '' : @internship_agreement.weekly_hours&.last
      end
      internship_offer_hours << if start_hours.blank? || end_hours.blank?
                                  [weekday.capitalize, '', '']
                                else
                                  [weekday.capitalize, "De #{start_hours.gsub(':', 'h')}",
                                   "A #{end_hours.gsub(':', 'h')}"]
                                end
    end
    @pdf.table(internship_offer_hours,
               column_widths: [@pdf.bounds.width / 3, @pdf.bounds.width / 3, @pdf.bounds.width / 3]) do |t|
      t.cells.padding = [5, 5, 5, 5]
    end

    # Objectifs assignés à la séquence d'observation en milieu professionnel
    @pdf.move_down 15
    label_form("Objectifs assignés à la séquence d'observation en milieu professionnel :")
    paraphing(
      "La séquence d'observation en milieu professionnel a pour objectif de "\
      "sensibiliser l'élève à l'environnement technologique, économique et "\
      "professionnel, en liaison avec les programmes d'enseignement, notamment "\
      "dans le cadre de son éducation à l'orientation."
    )

    @pdf.move_down 5
    html_formating('<div><span>Activités prévues :</span> ')
    @pdf.move_down 5
    html_formating("<div>#{@internship_agreement.activity_scope} </div>")
    @pdf.move_down 5

    html_formating('<div><span>Compétences visées :</span></div>')
    @pdf.move_down 5
    html_formating("<div style='margin-left: 15'><span>Observer (capacité de l'élève à décrire l'environnement professionnel qui l'accueille) :</span> </div>")
    html_formating("<div style='margin-left: 15'><span>Communiquer (savoir-être, posture de l'élève lorsqu'il s'adresse à ses interlocuteurs, les interroge ou leur fait des propositions) </span> </div>")
    html_formating("<div style='margin-left: 15'><span>Comprendre (esprit de curiosité manifesté par l'élève, capacité à analyser les enjeux du métiers, les relations entre les acteurs, les différentes phases de production, etc.) </span> </div>")
    html_formating("<div style='margin-left: 15'><span>S'impliquer (faire preuve de motivation, se proposer pour participer à certaines démarches) </span> </div>")
    @pdf.move_down 5
    paraphing("Modalités d'évaluation de la séquence d'observation en milieu professionnel : "\
      "La séquence d'observation doit être précédée d'un temps de préparation "\
      "et suivie d'un temps d'exploitation ou de restitution qui permet de "\
      "valoriser cette expérience. Les élèves peuvent s'exprimer sur ce qu'ils "\
      'ont vu, et revenir sur leurs activités et leurs impressions.')
  end

  def annexe_b
    label_form('B - Annexe financière')
    @pdf.move_down 5
    headering('1 – HÉBERGEMENT')
    @pdf.move_up 10
    paraphing("L'hébergement de l'élève en milieu professionnel n'entre pas dans le cadre de la présente convention.")

    headering('2 - RESTAURATION')
    @pdf.move_up 10
    paraphing('Rappel de la réglementation : l’élève peut accéder à l’espace restauration de l’entreprise ou de '\
    'l’organisme qui l’accueille dans les conditions fixées pour l’ensemble du personnel par le règlement intérieur de ce(tte) dernier(ère). '\
    'La participation financière des repas pris par l’élève en milieu professionnel demeure à la charge de son représentant légal. '\
    'L’organisme d’accueil peut décider de prendre en charge tout ou partie du coût du repas. '\
    "L’organisme d’accueil précise : #{@internship_agreement.lunch_break}")

    headering('3 - TRANSPORT')
    @pdf.move_up 10
    paraphing(
      "Le déplacement de l'élève est réglementé par la circulaire n°96-248 du "\
      "25 octobre 1996 susvisée. Dès lors que l'activité « séquence d'observation "\
      'en milieu professionnel » implique un déplacement qui se situe en début ou '\
      'en fin de temps scolaire, il est assimilé au trajet habituel entre le domicile '\
      "et l'établissement scolaire. L'élève, dans le cadre de l'apprentissage de l'autonomie, "\
      "peut s'y rendre ou en revenir seul."
    )
    headering('4 - ASSURANCE')
    @pdf.move_up 10
    paraphing(
      "La souscription d'une police d'assurance est obligatoire pour toutes les parties "\
      "concernées par la présente convention. Il convient de se rapporter à l'article 6 "\
      'de la convention pour en connaître les modalités.'
    )
  end

  def signatures
    if @internship_agreement.school_manager.present?
      @pdf.text "A #{@internship_agreement.school_manager.school.city.capitalize}, le #{Date.current.strftime('%d/%m/%Y')}."
    else
      @pdf.text "A #{@internship_agreement.internship_application.student.school.city.capitalize}, le #{Date.current.strftime('%d/%m/%Y')}."
    end
    @pdf.move_down 15

    @pdf.table([["La/le responsable de l'organisme d'accueil", "La/le chef(fe) d'établissement"]],
               cell_style: { border_width: 0 },
               column_widths: [@pdf.bounds.width / 2, @pdf.bounds.width / 2])

    @pdf.table([[
                 image_from(signature: download_image_and_signature(signatory_role: 'employer')),
                 image_from(signature: download_image_and_signature(signatory_role: 'school_manager'))
               ]], cell_style: { border_width: 0, height: 70 },
                   column_widths: [@pdf.bounds.width / 2, @pdf.bounds.width / 2])

    @pdf.move_down 15
    @pdf.text 'Vu et pris connaissance,'
    @pdf.move_down 15
    @pdf.table([['L’enseignant (ou les enseignants) éventuellement', 'L’enseignant (ou les enseignants) éventuellement']],
               cell_style: { border_width: 0 },
               column_widths: [@pdf.bounds.width / 2, @pdf.bounds.width / 2])
    @pdf.move_down 35
    @pdf.text 'Le responsable de l’accueil en milieu professionnel'
  end

  def signature_data
    { header: [[
      "Le chef d'établissement - #{school_manager.try(:presenter).try(:formal_name)}",
      "Le responsable de l'organisme d'accueil - #{employer.presenter.formal_name}",
      "L'élève",
      'Parents ou responsables légaux',
      'Le professeur référent',
      "Le référent en charge de l'élève à sein de l'organisme d'accueil"
    ]],
      body: [
        [''] * 6,
        [
          "Nom et prénom : #{school_manager.try(:presenter).try(:formal_name)}",
          "Nom et prénom : #{employer.presenter.formal_name}",
          "Nom et prénom : #{student.presenter.formal_name}",
          "Nom et prénom : #{dotting(@internship_agreement.student_legal_representative_full_name)}",
          "Nom et prénom : #{dotting(@internship_agreement.student_refering_teacher_full_name)}",
          "Nom et prénom : #{'.' * 58}"
        ],
        [
          signature_date_str(signatory_role: 'school_manager'),
          signature_date_str(signatory_role: 'employer'),
          "Signé le : #{'.' * 70}",
          "Signé le : #{'.' * 70}",
          "Signé le : #{'.' * 70}",
          "Signé le : #{'.' * 70}"
        ]
      ],
      signature_part: [
        [image_from(signature: download_image_and_signature(signatory_role: 'school_manager')),
         image_from(signature: download_image_and_signature(signatory_role: 'employer')),
         '',
         '',
         '',
         '']
      ] }
  end

  def signature_table_header(slice:)
    table_data = slice_by_two(signature_data[:header], slice:)
    @pdf.table(
      table_data,
      row_colors: ['F0F0F0'],
      column_widths: [PAGE_WIDTH / 2] * 2,
      cell_style: { size: 10 }
    ) do |t|
      t.cells.border_color = 'cccccc'
      t.cells.align = :center
    end
  end

  def signature_table_body(slice:)
    table_data = slice_by_two(signature_data[:body], slice:)

    @pdf.table(
      table_data,
      row_colors: ['FFFFFF'],
      column_widths: [PAGE_WIDTH / 2] * 2
    ) do |t|
      t.cells.borders = %i[left right]
      t.cells.border_color = 'cccccc'
      t.cells.height = 20
    end
  end

  def signature_table_signature(slice:)
    table_data = slice_by_two(signature_data[:signature_part], slice:)
    @pdf.table(
      table_data,
      row_colors: ['FFFFFF'],
      column_widths: [PAGE_WIDTH / 2] * 2
    ) do |t|
      t.cells.borders = %i[left right]
      t.cells.border_color = 'cccccc'
      t.cells.height = 100
    end
  end

  def signature_table_footer
    @pdf.table(
      [[''] * 2],
      row_colors: ['FFFFFF'],
      column_widths: [PAGE_WIDTH / 2] * 2,
      cell_style: { size: 8, color: '555555' }
    ) do |t|
      t.cells.borders = %i[left right bottom]
      t.cells.border_color = 'cccccc'
    end
  end

  def page_number
    string = '<page> / <total>'
    options = { at: [@pdf.bounds.right - 150, -40],
                width: 150,
                align: :right,
                page_filter: (1..7),
                start_count_at: 1,
                color: 'cccccc' }
    @pdf.number_pages string, options
  end

  def footer
    @pdf.repeat(:all) do
      @pdf.stroke_color '10008F'
      @pdf.stroke do
        @pdf.horizontal_line 0, 540, at: @pdf.bounds.bottom - 25
      end
      @pdf.text_box(internship_application.student.school.presenter.agreement_address,
                    align: :center,
                    at: [@pdf.bounds.left, @pdf.bounds.bottom - 35],
                    height: 20,
                    width: @pdf.bounds.width,
                    color: 'cccccc')
    end
  end

  def dotting(text, len = 35)
    text.nil? ? '.' * len : text
  end

  private

  def image_from(signature:)
    signature.nil? ? '' : { image: signature.local_signature_image_file_path }.merge(SIGNATURE_OPTIONS)
  end

  def download_image_and_signature(signatory_role:)
    signature = @internship_agreement.signature_by_role(signatory_role:)
    return nil if signature.nil?
    # When local images stay in the configurated storage directory
    return signature if Rails.application.config.active_storage.service == :local

    # When on external storage service , they are to be donwloaded
    img = signature.signature_image.try(:download) if signature.signature_image.attached?
    return nil if img.nil?

    File.open(signature.local_signature_image_file_path, 'wb') { |f| f.write(img) }
    signature
  rescue ActiveStorage::FileNotFoundError
    Rails.logger.error "Signature image not found for #{signatory_role} for internship agreement #{internship_agreement.id}"
    nil
  end

  def signature_date_str(signatory_role:)
    if @internship_agreement.signature_image_attached?(signatory_role:)
      return @internship_agreement.signature_by_role(signatory_role:).presenter.signed_at
    end

    ''
  end

  def subtitle(string)
    @pdf.text string, color: '10008F', style: :bold
    @pdf.move_down 10
  end

  def label_form(string)
    @pdf.text string, style: :bold, size: 10
    @pdf.move_down 5
  end

  # def field_form(string, html: false)
  #   html ? html_formating(string) : @pdf.text(string)
  #   @pdf.move_down 10
  # end

  def html_formating(string)
    @pdf.styled_text string
  end

  def titleing(text)
    @pdf.move_down 10
    subtitle text
    @pdf.move_down 5
  end

  def headering(text)
    label_form text
    @pdf.move_down 5
  end

  def paraphing(text)
    @pdf.text text
    @pdf.move_down 10
  end

  def paraphing_bold(text)
    @pdf.text text, style: :bold
    @pdf.move_down 10
  end

  def internship_offer
    @internship_agreement.internship_offer
  end

  def internship_application
    @internship_agreement.internship_application
  end

  def employer
    internship_application.internship_offer.employer
  end

  def school_manager
    internship_application.student.school_manager
  end

  def student
    internship_application.student
  end

  def referent_teacher
    internship_agreement.referent_teacher
  end

  def slice_by_two(array, slice:)
    table_data = []
    array.each do |row|
      table_data << row.each_slice(2).to_a[slice]
    end
    table_data
  end

  def enc(str)
    str ? str.encode('Windows-1252', 'UTF-8', undef: :replace, invalid: :replace) : ''
  end
end
