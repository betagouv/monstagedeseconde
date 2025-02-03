module Services::Omogen
  # Sygne eleves
  #  {
  #  "ine"=>"001291528AA",
  #  "nom"=>"SABABADICHETTY",
  #  "prenom"=>"Felix",
  #  "dateNaissance"=>"2003-05-28",
  #  "codeSexe"=>"1",
  #  "codeUai"=>"0590116F",
  #  "anneeScolaire"=>2023,
  #  "niveau"=>"2212",
  #  "libelleNiveau"=>"1ERE G-T",
  #  "codeMef"=>"20110019110",
  #  "libelleLongMef"=>"PREMIERE GENERALE",
  #  "codeMefRatt"=>"20110019110",
  #  "classe"=>"3E4",
  #  "codeRegime"=>"2",
  #  "libelleRegime"=>"DP DAN",
  #  "codeStatut"=>"ST",
  #  "libelleLongStatut"=>"SCOLAIRE",
  #  "dateDebSco"=>"2023-09-05",
  #  "adhesionTransport"=>false
  # }
  class SygneEleve
    attr_reader :ine, :nom, :prenom, :date_naissance, :code_sexe, :code_uai, :annee_scolaire,
                :niveau, :libelle_niveau, :code_mef, :libelle_long_mef, :code_mef_ratt, :classe,
                :code_regime, :libelle_regime, :code_statut, :libelle_long_statut,
                :date_deb_sco, :adhesion_transport, :grade, :school, :responsible

    def make_student
      return if Users::Student.find_by(ine: ine)

      scrambled_ine = Digest::SHA1.hexdigest(ine)
      student = ::Users::Student.new(
        ine: ine,
        first_name: prenom,
        last_name: nom,
        birth_date: date_naissance,
        school_id: school.id,
        gender: gender,
        class_room_id: class_room.id,
        grade_id: grade.id,
        accept_terms: true,
        email: "#{scrambled_ine}@#{school.code_uai}.fr"
      )
      # "#{responsible.civility} #{responsible.first_name} #{responsible.last_name}",
      # legal_representative_email: responsible.email,
      # legal_representative_phone: responsible.phone,
      student.password = "#{ine}#{school.code_uai}!zZtest"
      puts student.errors.full_messages unless student.save
    end

    def class_room
      raise 'missing code_mef' if code_mef.blank?
      raise "missing grade with #{code_mef}" if grade.blank?

      ClassRoom.find_or_create_by(
        name: classe,
        school_id: school.id,
        grade_id: grade.id
      )
    end

    private

    def initialize(hash)
      @ine = hash[:ine]
      @nom = hash[:nom]
      @prenom = hash[:prenom]
      @date_naissance = hash[:dateNaissance]
      @code_sexe = hash[:codeSexe]
      @code_uai = hash[:codeUai]
      @annee_scolaire = hash[:anneeScolaire]
      @niveau = hash[:niveau]
      @libelle_niveau = hash[:libelleNiveau]
      @code_mef = hash[:codeMef]
      @libelle_long_mef = hash[:libelleLongMef]
      @code_mef_ratt = hash[:codeMefRatt]
      @classe = hash[:classe]
      @code_regime = hash[:codeRegime]
      @libelle_regime = hash[:libelleRegime]
      @code_statut = hash[:codeStatut]
      @libelle_long_statut = hash[:libelleLongStatut]
      @date_deb_sco = hash[:dateDebSco]
      @adhesion_transport = hash[:adhesionTransport]

      @school = School.find_by(code_uai: code_uai)
      @grade = Grade.grade_by_mef(code_mef: code_mef)
      # Following line takes too much time
      # @responsible = Services::Omogen::Sygne.new.sygne_responsable(@ine)
    end

    def gender
      case @code_sexe
      when '1'
        'm'
      when '2'
        'f'
      else
        'np'
      end
    end
  end
end
