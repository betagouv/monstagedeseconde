require 'cgi'
require 'open-uri'
include ApplicationHelper

class GenerateInternshipAgreement < Prawn::Document

  def initialize(internship_agreement_id)
    @internship_agreement = InternshipAgreement.find(internship_agreement_id)
    @pdf = Prawn::Document.new(margin: [40, 40, 100, 40])
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
    (0..2).each do |slice|
      signature_table_header(slice: slice)
      signature_table_body(slice: slice)
      signature_table_signature(slice: slice)
      signature_table_footer
      @pdf.move_down 20
    end

    footer
    page_number
    @pdf
  end

  def header
    y_position = @pdf.cursor
    # @pdf.image "#{Rails.root}/public/assets/logo.png", at: [0, y_position], width: 50
    @pdf.move_down 5
    @pdf.move_down 30
  end

  def title
    title = "Convention relative à l'organisation de la séquence d'observation en milieu "\
            "professionnel pour les élèves de seconde de lycée général et technologique"
    @pdf.move_down 20
    @pdf.text title, :size => 16, :align => :left, :color => "10008F"
    @pdf.move_down 20
  end

  def intro
    paraphing("Vu le code du travail, notamment ses articles L. 4153-1 ;")
    paraphing("Vu le code de l'éducation, et notamment ses articles L. 124-1, L. 134-9, L. 313-1, "\
      "L. 331-4, L. 331-5, L. 332-3, L. 335-2, L. 411-3, L. 421-7, L. 911-4, D. 331-1 à D. 331-9, D. 333-3-1;")
    paraphing("Vu le code civil, et notamment ses articles 1240 à 1242;")
    paraphing("Vu la circulaire n°96-248 du 25 octobre 1996 relative à la surveillance des élèves ;")
    paraphing("Vu la circulaire du 13 juin 2023 relative à l’organisation des "\
      "sorties et voyages scolaires dans les écoles, les collèges et les lycées publics ;")
    paraphing("Vu la circulaire MENE2400643C du 28 mars 2024 relative aux séquences d’observation pour les élèves de seconde de lycée général et technologique ;")
    @pdf.move_down 20
  end

  def contractors
    label_form("Entre")
    paraphing("L'entreprise ou l'organisme d'accueil, représentée par M/Mme "\
      "#{@internship_agreement.organisation_representative_full_name}, en qualité "\
      "de chef(fe) d'entreprise ou de responsable de l'organisme d'accueil d'une part, et")
    paraphing("L'établissement d'enseignement scolaire, représenté par M/Mme "\
      "#{@internship_agreement.school_representative_full_name}, en qualité de "\
      "chef(fe) d'établissement d'autre part,")
    paraphing("Il a été convenu ce qui suit :")
  end

  def article_1
    headering("TITRE I : DISPOSITIONS GÉNÉRALES")
    headering("Art 1er .")
    paraphing("La présente convention a pour objet la mise en œuvre d'une séquence "\
      "d'observation en milieu professionnel, au bénéfice des élèves scolarisés en "\
      "classe de seconde de lycée d’enseignement général et technologique.")
  end

  def article_2
    headering("Art 2 .")
    paraphing("Les objectifs et les modalités de la séquence d'observation sont consignés dans l'annexe pédagogique.")
    paraphing("Les modalités de prise en charge des frais afférents à cette "\
    "séquence ainsi que les modalités d'assurances sont définies dans l'annexe financière.")
  end

  def article_3
    headering("Art 3 .")
    paraphing("L'organisation de la séquence d'observation est déterminée d'un "\
    "commun accord entre la/le chef(fe) d'entreprise ou la/le responsable de "\
    "l'organisme d'accueil et la/le chef(fe) d'établissement.")
  end

  def article_4
    headering("Art 4 .")
    paraphing("Les élèves demeurent sous statut scolaire durant la période "\
    "d'observation en milieu professionnel. Ils restent placés sous l'autorité "\
    "et la responsabilité du chef(fe) d'établissement.")
    paraphing("Ils ne peuvent prétendre à aucune rémunération ou gratification de l'entreprise ou de l'organisme d'accueil.")
  end

  def article_5
    headering("Art 5 .")
    paraphing("Durant la séquence d'observation, les élèves n'ont pas à concourir au travail dans l'entreprise ou l'organisme d'accueil.")
    paraphing(
      "Au cours des séquences d'observation, les élèves peuvent effectuer des "\
      "enquêtes en liaison avec les enseignements. Ils peuvent également participer "\
      "à des activités de l'entreprise ou de l'organisme d’accueil, à des essais ou à "\
      "des démonstrations en liaison avec les enseignements et les objectifs de formation "\
      "de leur classe, sous le contrôle des personnels responsables de leur encadrement "\
      "en milieu professionnel.")
    paraphing(
      "Les élèves ne peuvent accéder aux machines, appareils ou produits dont l'usage "\
      "est proscrit aux mineurs par les articles D. 4153-15 à D. 4153-37 du code du "\
      "travail. Ils ne peuvent ni procéder à des manœuvres ou manipulations sur d'autres "\
      "machines, produits ou appareils de production ni effectuer des travaux légers "\
      "autorisés aux mineurs par ce même code."
    )
  end

  def article_6
    headering("Art 6 .")
    paraphing(
      "La/le chef(fe) d'entreprise ou la/le responsable de l'organisme d'accueil prend "\
      "les dispositions nécessaires pour garantir sa responsabilité civile chaque fois "\
      "qu'elle sera engagée (en application des articles 1240 à 1242 du code civil) :")
    html_formating "<div style='margin-left: 35'>- soit en souscrivant une assurance "\
      "particulière garantissant sa responsabilité "\
      "civile en cas de faute imputable à l'entreprise ou à l'organisme d'accueil à "\
      "l'égard de l'élève ;"
    @pdf.move_down 10
    html_formating "<div style='margin-left: 35'>- soit en ajoutant à son contrat "\
      "déjà souscrit au titre de la “responsabilité "\
      "civile entreprise” ou de la  “responsabilité civile professionnelle,” un avenant "\
      "relatif à l'accueil d'élèves."
    @pdf.move_down 10
    paraphing(
      "La/le chef(fe) de l'établissement d'enseignement contracte une assurance couvrant "\
      "la responsabilité civile des élèves placés sous sa responsabilité pour les dommages "\
      "qu'ils pourraient causer à l’occasion de la visite d'information ou de la séquence "\
      "d'observation en milieu professionnel, ainsi qu'en dehors de l'entreprise ou de "\
      "l'organisme d’accueil, ou sur le trajet menant, soit au lieu où se déroule la visite "\
      "d’information ou la séquence d’observation, soit au domicile.")
    paraphing(
      "L’élève (et en cas de minorité ses représentants légaux) doit souscrire et produire "\
      "une attestation d’assurance couvrant sa responsabilité civile pour les dommages qu’il "\
      "pourrait causer ou qui pourraient lui advenir en milieu professionnel, dont la cause ne "\
      "serait imputable ni à l’entreprise ou à l’organisme d’accueil, ni au chef(fe) "\
      "d’établissement en application de l'article L. 911-4 du code de l'éducation ou "\
      "de la responsabilité administrative pour mauvaise organisation du service.")
  end

  def article_7
    headering("Art 7 .")
    paraphing(
      "En cas d'accident survenant à l'élève, soit en milieu professionnel, soit au cours "\
      "du trajet, la/le chef(fe) d’entreprise ou responsable de l'organisme d’accueil alerte "\
      "sans délai la/le chef(fe) d’établissement d’enseignement de l’élève par tout moyen mis "\
      "à sa disposition et lui adresse la déclaration d'accident dûment renseignée dans la "\
      "même journée.")
  end

  def article_8
    headering("Art 8 .")
    paraphing(
      "La/le chef(fe) d'établissement d'enseignement et la/le chef(fe) d'entreprise ou la/le "\
      "responsable de l'organisme d'accueil de l'élève se tiendront mutuellement informés des "\
      "difficultés qui pourraient naître de l'application de la présente convention et prendront, "\
      "d'un commun accord et en liaison avec l'équipe pédagogique, les dispositions propres à les "\
      "résoudre notamment en cas de manquement à la discipline. Les difficultés qui pourraient être "\
      "rencontrées lors de toute période en milieu professionnel et notamment toute absence d'un "\
      "élève, seront aussitôt portées à la connaissance du chef(fe) d'établissement.")
  end

  def article_9
    headering("Art 9 ." )
    paraphing("La présente convention est signée pour la durée d'une séquence d'observation en milieu professionnel, fixée à :")
    html_formating "<div style='margin-left: 35'>-  5 jours consécutifs ou non, pour les élèves scolarisés en collège (facultatif en quatrième, obligatoire en troisième) ;</div>"
    @pdf.move_down 10
    html_formating "<div style='margin-left: 35'>-  une (si deux lieux différents) ou deux semaines consécutives, pour les élèves scolarisés en seconde générale ou technologique durant le dernier mois de l’année scolaire.</div>"    
  end

  def article_bonus
    return unless @internship_agreement.student.school.agreement_conditions_rich_text.present?
    headering("Art 10 .")
    html_formating "<div style=''>#{@internship_agreement.student.school.agreement_conditions_rich_text.body.html_safe}</div>"
    @pdf.move_down 30
  end

  def annexe_a
    headering("TITRE II : DISPOSITIONS PARTICULIÈRES")

    headering("A - Annexe pédagogique")
    @pdf.move_down 20
    @pdf.text "Prénom et nom de l'élève : #{student.presenter.formal_name} "
    @pdf.move_down 20
    @pdf.text "Date de naissance : #{student.presenter.birth_date} "
    @pdf.move_down 20
    @pdf.text "Classe : #{dotting student&.class_room&.name}"
    @pdf.move_down 20
    @pdf.text "Prénom, nom et coordonnées électronique et téléphonique des représentants légaux :"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_legal_representative_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_legal_representative_email} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_legal_representative_phone} </div>"
    @pdf.move_down 20
    @pdf.text "Prénom, nom du chef(fe) d’établissement, adresse postale et électronique du lieu de scolarisation dont relève l’élève :"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_representative_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_representative_role} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_manager.email} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.school_representative_phone} </div>"
    @pdf.move_down 20
    @pdf.text "Statut de l’établissement scolaire : #{@internship_agreement.legal_status.try(:capitalize)}"
    @pdf.move_down 20
    @pdf.text "Prénom, nom du tuteur ou du responsable de l'accueil en milieu professionnel et sa qualité :"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.tutor_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.tutor_role} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.tutor_email} </div>"
    @pdf.move_down 20
    @pdf.text "Prénom et nom et coordonnées électronique et téléphonique du ou (des) enseignant(s) "\
      "référent(s) chargé(s) du suivi de la séquence d'observation en milieu professionnel :"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_email} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_phone} </div>"
    @pdf.move_down 20
    paraphing("Dates de la séquence d'observation en milieu professionnel :")
    paraphing("La séquence d’observation en milieu professionnel se déroule pendant #{@internship_agreement.internship_offer.period_label} inclus.")
    @pdf.move_down 20

    # Repères réglementaires relatifs à la législation sur le travail
    label_form("Repères réglementaires relatifs à la législation sur le travail :")
    @pdf.move_down 20
    paraphing("Les durées maximales de travail hebdomadaires sont de 35 heures et quotidiennes de 8 heures.")
    paraphing("Les repos quotidiens de l’élève sont respectivement de 12 heures consécutives au minimum et hebdomadaire de 2 jours consécutifs.")
    paraphing("Dès lors que le temps de travail quotidien atteint 4 heures 30, l’élève doit bénéficier d’un temps de pause de 30 minutes consécutives minimum.")
  
    @pdf.text "Les horaires journaliers de l'élève sont précisés ci-dessous :"
    @pdf.move_down 10

    internship_offer_hours = []
    %w(lundi mardi mercredi jeudi vendredi).each_with_index do |weekday, i|
      if @internship_agreement.daily_planning?
        start_hours = @internship_agreement.daily_hours&.dig(weekday)&.first
        end_hours = @internship_agreement.daily_hours&.dig(weekday)&.last
      else
        start_hours = @internship_agreement.weekly_hours&.first
        end_hours = @internship_agreement.weekly_hours&.last
      end
      if start_hours.blank? || end_hours.blank?
        internship_offer_hours << [weekday.capitalize, ""]
      else
        internship_offer_hours << [weekday.capitalize, "De #{start_hours.gsub(':', 'h')}", "A #{end_hours.gsub(':', 'h')}"] 
      end
    end
    @pdf.table(internship_offer_hours,  column_widths: [@pdf.bounds.width / 3, @pdf.bounds.width / 3, @pdf.bounds.width / 3]) do |t|
      t.cells.padding = [10, 10, 10, 10]
    end
    @pdf.move_down 20

    # Objectifs assignés à la séquence d'observation en milieu professionnel
    @pdf.move_down 20
    label_form("Objectifs assignés à la séquence d'observation en milieu professionnel :")
    paraphing(
      "La séquence d'observation en milieu professionnel a pour objectif de "\
      "sensibiliser l’élève à l'environnement technologique, économique et "\
      "professionnel, en liaison avec les programmes d'enseignement, notamment "\
      "dans le cadre de son éducation à l'orientation.")
    paraphing(
      "Modalités de la concertation qui sera assurée pour organiser la  "\
      "préparation, contrôler le déroulement de la période en vue d'une  "\
      "véritable complémentarité des enseignements reçus :" )
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_full_name} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_email} </div>"
    html_formating "<div style='margin-left: 35'> #{@internship_agreement.student_refering_teacher_phone} </div>"
    @pdf.move_down 20

    @pdf.move_down 20
    html_formating("<div><span>Activités prévues :</span> ")
    @pdf.move_down 20
    html_formating("<div>#{@internship_agreement.activity_scope_rich_text} </div>")
    @pdf.move_down 20


    html_formating("<div><span>Compétences visées :</span></div>")
    @pdf.move_down 20
    html_formating("<div style='margin-left: 35'><span>Observer (capacité de l’élève à décrire l’environnement professionnel qui l’accueille) :</span> #{@internship_agreement.skills_observe_rich_text}</div>")
    @pdf.move_down 20
    html_formating("<div style='margin-left: 35'><span>Communiquer (savoir-être, posture de l’élève lorsqu’il s’adresse à ses interlocuteurs, les interroge ou leur fait des propositions) </span> : #{@internship_agreement.skills_communicate_rich_text} </div>")
    @pdf.move_down 20
    html_formating("<div style='margin-left: 35'><span>Comprendre (esprit de curiosité manifesté par l’élève, capacité à analyser les enjeux du métiers, les relations entre les acteurs, les différentes phases de production, etc.) </span> : #{@internship_agreement.skills_understand_rich_text} </div>")  
    @pdf.move_down 20
    html_formating("<div style='margin-left: 35'><span>S’impliquer (faire preuve de motivation, se proposer pour participer à certaines démarches) </span> : #{@internship_agreement.skills_motivation_rich_text} </div>")
    @pdf.move_down 20


    paraphing("Modalités d'évaluation de la séquence d'observation en milieu professionnel :")
    html_formating("<div>#{@internship_agreement.activity_rating_rich_text} </div>")
    @pdf.move_down 20
    paraphing(
      "La séquence d'observation doit être précédée d'un temps de préparation "\
      "et suivie d'un temps d'exploitation ou de restitution qui permet de "\
      "valoriser cette expérience. Les élèves peuvent s’exprimer sur ce qu’ils "\
      "ont vu, et revenir sur leurs activités et leurs impressions.")
  end

  def annexe_b
    label_form("B - Annexe financière")
    @pdf.move_down 20
    headering("1 – HÉBERGEMENT")
    paraphing("L’hébergement de l’élève en milieu professionnel n’entre pas dans le cadre de la présente convention.")
    headering("2 - RESTAURATION")
    @pdf.move_down 10
    @pdf.text @internship_agreement.lunch_break
    @pdf.move_down 10
    headering("3 - TRANSPORT")
    paraphing(
      "Le déplacement de l’élève est réglementé par la circulaire n°96-248 du "\
      "25 octobre 1996 susvisée. Dès lors que l'activité « séquence d’observation "\
      "en milieu professionnel » implique un déplacement qui se situe en début ou "\
      "en fin de temps scolaire, il est assimilé au trajet habituel entre le domicile "\
      "et l'établissement scolaire. L’élève, dans le cadre de l’apprentissage de l’autonomie, "\
      "peut s’y rendre ou en revenir seul."
    )
    headering("4 - ASSURANCE")
    paraphing(
      "La souscription d’une police d’assurance est obligatoire pour toutes les parties "\
      "concernées par la présente convention. Il convient de se rapporter à l’article 6 "\
      "de la convention pour en connaître les modalités.")
    @pdf.move_down 40
  end
  
  def signatures
    @pdf.text "A #{@internship_agreement.school_manager.school.city.capitalize}, le #{(Date.current).strftime('%d/%m/%Y')}."

    @pdf.move_down 20
  end

  def signature_data
    { header: [[
        "Le chef d'établissement",
        "Le responsable de l'organisme d'accueil",
        "L'élève",
        "Les parents       (responsables légaux)",
        "Le professeur référent",
        "Le référent en charge de l’élève à sein de l’organisme d’accueil"
        ]],
      body: [
        [""]*6,
        [
          "Nom et prénom : #{school_manager.presenter.formal_name}",
          "Nom et prénom : #{employer.presenter.formal_name}",
          "Nom et prénom : #{student.presenter.formal_name}",
          "Nom et prénom : #{dotting(@internship_agreement.student_legal_representative_full_name)}",
          "Nom et prénom : #{dotting(@internship_agreement.student_refering_teacher_full_name)}",
          "Nom et prénom : #{"." *58}"
        ],
        [
          signature_date_str(signatory_role:'school_manager'),
          signature_date_str(signatory_role:'employer'),
          "Signé le : #{"." * 70}",
          "Signé le : #{"." * 70}",
          "Signé le : #{"." * 70}",
          "Signé le : #{"." * 70}"
        ]],
      signature_part: [
        [image_from(signature: download_image_and_signature(signatory_role: 'school_manager')),
         image_from(signature: download_image_and_signature(signatory_role: 'employer')),
         "",
         "",
         "",
         ""]]
    }
  end

  def signature_table_header(slice:)
    table_data = slice_by_two(signature_data[:header], slice: slice)
    @pdf.table(
      table_data,
      row_colors: ["F0F0F0"],
      column_widths: [PAGE_WIDTH / 2] * 2,
      cell_style: {size: 10}
    ) do |t|
        t.cells.border_color="cccccc"
        t.cells.align=:center
    end
  end

  def signature_table_body(slice:)
    table_data = slice_by_two(signature_data[:body], slice: slice)

    @pdf.table(
      table_data,
      row_colors: ["FFFFFF"],
      column_widths: [PAGE_WIDTH / 2] * 2
    )  do |t|
      t.cells.borders = [:left, :right]
      t.cells.border_color="cccccc"
      t.cells.height= 20
    end
  end

  def signature_table_signature(slice:)
    table_data = slice_by_two(signature_data[:signature_part], slice: slice)
    @pdf.table(
      table_data,
      row_colors: ["FFFFFF"],
      column_widths: [PAGE_WIDTH / 2] * 2
    )  do |t|
      t.cells.borders = [:left, :right]
      t.cells.border_color="cccccc"
      t.cells.height= 100
    end
  end

  def signature_table_footer
    @pdf.table(
      [[""] * 2],
      row_colors: ["FFFFFF"],
      column_widths: [PAGE_WIDTH / 2] * 2,
      cell_style: {size: 8, color: '555555'}
    )  do |t|
      t.cells.borders = [:left, :right, :bottom]
      t.cells.border_color="cccccc"
    end
  end

  def page_number
    string = '<page> / <total>'
    options = { :at => [@pdf.bounds.right - 150, -40],
                :width => 150,
                :align => :right,
                :page_filter => (1..7),
                :start_count_at => 1,
                :color => "cccccc" }
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
                    :at => [@pdf.bounds.left, @pdf.bounds.bottom - 35],
                    :height => 20,
                    :width => @pdf.bounds.width,
                    color: 'cccccc')
    end
  end

  def dotting(text, len = 35)
    text.nil? ? '.' * len : text
  end



  private



  def image_from(signature: )
    signature.nil? ? "" : {image: signature.local_signature_image_file_path}.merge(SIGNATURE_OPTIONS)
  end

  def download_image_and_signature(signatory_role:)
    signature = @internship_agreement.signature_by_role(signatory_role: signatory_role)
    return nil if signature.nil?
    # When local images stay in the configurated storage directory
    return signature if Rails.application.config.active_storage.service == :local

    # When on external storage service , they are to be donwloaded
    img = signature.signature_image.try.download if signature.signature_image.attached?
    return nil if img.nil?

    File.open(signature.local_signature_image_file_path, "wb") { |f| f.write(img) }
    signature
  rescue ActiveStorage::FileNotFoundError
    nil
  end

  def signature_date_str(signatory_role:)
    if @internship_agreement.signature_image_attached?(signatory_role: signatory_role)
      return @internship_agreement.signature_by_role(signatory_role: signatory_role).presenter.signed_at
    end

    ''
  end

  def subtitle(string)
    @pdf.text string, :color => "10008F", :style => :bold
    @pdf.move_down 10
  end

  def label_form(string)
    @pdf.text string, :style => :bold, size: 10
    @pdf.move_down 5
  end

  # def field_form(string, html: false)
  #   html ? html_formating(string) : @pdf.text(string)
  #   @pdf.move_down 10
  # end

  def html_formating(string)
    @pdf.styled_text string
  end

  def headering(text)
    @pdf.move_down 10
    label_form text
    @pdf.move_down 10
  end

  def paraphing(text)
    @pdf.text text
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
    str ? str.encode("Windows-1252","UTF-8", undef: :replace, invalid: :replace) : ''
  end
end
