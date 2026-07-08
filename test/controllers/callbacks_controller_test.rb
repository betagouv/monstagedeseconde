require "test_helper"
class CallbacksControllerTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  setup do
    lille_academy = Academy.find_by(name: "Académie de Lille")
    nord = Department.find_by(code: "59")
    @school = create(:school, code_uai: "0590121L", zipcode: "59000", department: nord)
    @school2 = create(:school, code_uai: "0590121X", zipcode: "59000", department: nord)
    @school3 = create(:school, code_uai: "0590121Y", zipcode: "59000", department: nord)
    @school4 = create(:school, code_uai: "0590121Z", zipcode: "59000", department: nord)
    @student = create(:student,
                      ine: "1234567890",
                      confirmed_at: nil,
                      school: @school,
                      legal_representative_email: nil,
                      legal_representative_full_name: nil,
                      legal_representative_phone: nil)

    @code = "123456"
    @state = "abc"
    @nonce = "def"
    get root_path
    stub_omogen_auth
    cookies[:state] = @state
    @omogen = Services::Omogen::Sygne.new
  end

  #  FIM PART

  test "should get fim token and create SchoolManager user" do
    fim_token_stub
    fim_school_manager_userinfo_stub

    assert_difference "User.count", 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_equal "Users::SchoolManagement", User.last.type
    assert_equal "school_manager", User.last.role
    assert_equal "0590121L", User.last.school.code_uai
    assert_not_nil User.last.fim_user_info
  end
  test "should get fim token and does not create user if school is not found" do
    fim_token_stub
    fim_teacher_without_school_userinfo_stub

    assert_no_difference "User.count" do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
  end

  test "should get fim token and create Teacher user" do
    fim_token_stub
    fim_teacher_userinfo_stub

    assert_difference "User.count", 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_equal "Users::SchoolManagement", User.last.type
    assert_equal "teacher", User.last.role
    assert_equal "0590121L", User.last.school.code_uai
  end

  test "should get fim token and create Teacher user with 3 schools" do
    fim_token_stub
    fim_teacher_userinfo_stub

    assert_difference "User.count", 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end
    assert_no_difference "User.count" do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_equal "Users::SchoolManagement", User.last.type
    assert_equal "teacher", User.last.role
    assert_equal "0590121L", User.last.school.code_uai
    assert_equal 4, User.last.schools.count
  end

  test "should get fim token and update already created Teacher user with 4 schools" do
    fim_token_stub
    fim_teacher_userinfo_stub

    puts @school.email_domain_name
    teacher = create(:teacher, school: @school, email: "jean.dupont@ac-lille.fr")

    assert_difference "User.count", 0 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    teacher.reload
    assert_equal "Users::SchoolManagement", teacher.type
    assert_equal "teacher", teacher.role
    assert_equal "0590121L", teacher.school.code_uai
    assert_equal 4, teacher.schools.count
  end

  test "should get fim token and create admin_officer role user" do
    fim_token_stub
    fim_admin_userinfo_stub

    assert_difference "User.count", 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_equal "Users::SchoolManagement", User.last.type
    assert_equal "admin_officer", User.last.role
    assert_equal "0590121L", User.last.school.code_uai
  end

  test "should get fim token and create admin_officer role user with a school_officer of a different school when invited" do
    invitee_email = "nathalie.dupont@ac-lille.fr"
    other_school = create(:school, code_uai: "01255552P", city: "Lille", zipcode: "59000", name: "Lycée de Lille")
    other_school_admin = create(:school_manager, school: other_school, email: "pierre.durand@ac-lille.fr")
    invitation = Invitation.create!(
      first_name: "Nathalie",
      last_name: "Dupont",
      email: invitee_email,
      user: other_school_admin,
      sent_at: 2.days.ago
    )
    # school_manager = invitation.author
    fim_token_stub
    fim_admin_userinfo_stub

    assert_difference "User.count", 1 do
      get fim_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    registered_user = User.last
    assert_equal "Users::SchoolManagement", registered_user.type
    assert_equal "admin_officer", registered_user.role
    assert_equal "01255552P", registered_user.school.code_uai
    assert_equal "0590121L", registered_user.fim_user_info["original_rne"]
    assert_equal invitee_email, registered_user.email
  end

  # EDUCONNECT PART

  test "should get educonnect token and confirm student user" do
    educonnect_token_stub
    educonnect_userinfo_stub
    stub_sygne_eleve(ine: "1234567890", token: @omogen.token, code_uai: "0590121L")
    stub_sygne_responsible(ine: "1234567890", token: @omogen.token)
    educonnect_logout_stub

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    @student.reload
    assert_response :redirect
    refute_nil @student.confirmed_at
    # assert_equal '07509232q', @student.school.code_uai # always change ?
    assert_equal "I*************@email.co", @student.legal_representative_email
    assert_equal "Mme Frederic CHIERICI", @student.legal_representative_full_name
    assert_equal "0506070809", @student.legal_representative_phone
    assert_nil @student.fim_user_info
  end

  test "should redirect with explicit message when parent connects with educonnect and UAI is blank" do
    educonnect_token_stub
    educonnect_userinfo_responsible_stub
    educonnect_logout_stub

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    assert_response :redirect
    assert_redirected_to root_path
    assert_match "réservée aux élèves", flash[:alert]
  end

  test "should get educonnect token and does not logged in user if student is unknown" do
    educonnect_token_stub
    educonnect_userinfo_unknown_stub
    educonnect_logout_stub

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    assert_response :redirect
    assert_nil @student.confirmed_at
  end

  test "a registered student logs in via Educonnect without any Sygne call" do
    @student.destroy
    former_school = create(:school, code_uai: "9590121X")
    former_class_room = create(:class_room, name: "Former Class Room", school: former_school)
    student = create(:student, ine: "1234567890", school: former_school, class_room: former_class_room,
                               confirmed_at: nil, legal_representative_full_name: "Mme Present")

    educonnect_token_stub
    educonnect_userinfo_stub
    # Aucun stub SYGNE : WebMock lèverait si le flux appelait SYGNE pour un élève existant.

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    assert_response :redirect
    student.reload
    refute_nil student.confirmed_at
    # Établissement / classe inchangés : plus de resynchronisation SYGNE à la connexion.
    assert_equal "9590121X", student.school.code_uai
    assert_equal "Former Class Room", student.class_room.name
  end

  test "rejects a student whose Educonnect level is not authorized, without calling Sygne" do
    educonnect_token_stub
    educonnect_userinfo_ineligible_level_stub # FrEduCtEleveNiveau "2212" (1ERE) => non autorisé
    educonnect_logout_stub
    # Aucun stub SYGNE : le refus doit intervenir avant tout appel SYGNE.

    get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }

    assert_redirected_to root_path
    assert_match "peuvent se connecter", flash[:alert]
    @student.reload
    assert_nil @student.confirmed_at
  end

  test "creates the student using the SYGNE identity (nomFamille/prenom1)" do
    @student.destroy
    educonnect_token_stub
    educonnect_userinfo_stub
    # Le per-INE SYGNE renvoie l'identité sous nomFamille/prenom1 (scolarité imbriquée).
    stub_sygne_eleve(ine: "1234567890", token: @omogen.token, code_uai: "0590121L",
                     nom_famille: "ARMSTRONG", prenom1: "Jamie")
    stub_sygne_responsible(ine: "1234567890", token: @omogen.token)

    assert_difference "Users::Student.count", 1 do
      get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    student = Users::Student.find_by(ine: "1234567890")
    assert_equal "Jamie", student.first_name
    assert_equal "ARMSTRONG", student.last_name
    assert student.created_by_system
  end

  test "should create student account on the fly when eligible and unknown" do
    @student.destroy
    educonnect_token_stub
    educonnect_userinfo_stub
    stub_sygne_eleve(ine: "1234567890", token: @omogen.token, code_uai: "0590121L", classe: "3E4")
    stub_sygne_responsible(ine: "1234567890", token: @omogen.token)

    assert_difference "Users::Student.count", 1 do
      get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    student = Users::Student.find_by(ine: "1234567890")
    assert_equal "0590121L", student.school.code_uai
    refute_nil student.confirmed_at
    assert student.created_by_system
  end

  test "should reject and not create account when student is unknown to Sygne (404)" do
    @student.destroy
    educonnect_token_stub
    educonnect_userinfo_stub
    stub_sygne_eleve_not_found(ine: "1234567890", token: @omogen.token)
    educonnect_logout_stub

    assert_no_difference "Users::Student.count" do
      get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_redirected_to root_path
    assert_match "peuvent se connecter", flash[:alert]
  end

  test "should reject and not create account when Sygne scolarite is not eligible" do
    @student.destroy
    educonnect_token_stub
    educonnect_userinfo_stub
    # code_mef 211... => non éligible (hors 4e/3e/2nde GT)
    stub_sygne_eleve(ine: "1234567890", token: @omogen.token, code_uai: "0590121L", code_mef: "21100019110")
    educonnect_logout_stub

    assert_no_difference "Users::Student.count" do
      get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_redirected_to root_path
    assert_match "peuvent se connecter", flash[:alert]
  end

  test "should reject gracefully without 500 when Sygne errors" do
    @student.destroy
    educonnect_token_stub
    educonnect_userinfo_stub
    stub_sygne_eleve(ine: "1234567890", token: @omogen.token, code_uai: "0590121L", status: 500)
    educonnect_logout_stub

    assert_no_difference "Users::Student.count" do
      get educonnect_callback_path, params: { code: @code, state: @state, nonce: @nonce }
    end

    assert_response :redirect
    assert_redirected_to root_path
  end
end
