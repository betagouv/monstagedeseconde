# frozen_string_literal: true

# Job responsible for rebuilding reviews and broadcasting progress updates.
class RebuildReviewJob < ApplicationJob
  include ReviewRebuild::EmployersCreationSteps
  include ReviewRebuild::OffersCreationSteps
  include ReviewRebuild::SchoolManagementUpdateSteps
  include ReviewRebuild::StudentsCreationSteps
  include ReviewRebuild::ApplicationsCreationSteps
  include ReviewRebuild::AgreementsCreationSteps
  include ReviewRebuild::InvitationsCreationSteps
  include ReviewRebuild::TeamsCreationSteps
  include ReviewRebuild::BoardingHousesCreationSteps
  queue_as :default
  sidekiq_options retry: false

  def perform(job_id)
    # @message_box = message_box
    @job_id = job_id
    rebuild_steps_percentages_and_launch_process
    launch_rebuild_process
  end

  # Steps can evolve over time by just adding or removing steps
  #
  STEPS = [
    # removal steps
    [ :boarding_house_views_removal, "Suppression des vues de l'internat", 1, "removal" ],
    [ :mail_action_item_removal, "Suppression des MailActionItems", 1, "removal" ],
    [ :invitation_removal, "Suppression des invitations de personnels pédagogiques", 1, "removal" ],
    [ :favorites_removal, "Suppression des favoris des élèves", 1, "removal" ],
    [ :student_removal, "Suppression des élèves, de leurs candidatures, de leurs conventions, des signatures", 5,
     "removal" ],
    [ :student_search_history_removal, "Suppression des historiques de recherche des élèves", 2, "removal" ],
    [ :waiting_list_entries_removal, "Suppression des listes d'attente[waiting_list_entries]", 1, "removal" ],
    [ :team_removal, "Suppression des équipes", 1, "removal" ],
    [ :stepper_classes_removal, "Suppression du contenu des tables du stepper", 1, "removal" ],
    [ :api_offers_removal, "Suppression des offres api", 1, "removal" ],
    [ :local_offers_removal, "Suppression des offres locales 1E1S", 1, "removal" ],
    [ :areas_removal, "Suppression des espaces et des offres", 1, "removal" ],
    [ :notifications_removal, "Suppression des notifications", 1, "removal" ],
    [ :user_area_removal, "Suppression des espaces utilisateur", 1, "removal" ],
    [ :employers_removal, "Suppression des employeurs et de leurs offres", 1, "removal" ],
    [ :users_operator_removal, "Suppression des opérateurs", 1, "removal" ],
    [ :users_school_management_removal, "Suppression des équipes pédagogiques", 1, "removal" ],
    [ :corporation_removal, "Suppression des entreprises du multi-entreprise", 1, "removal" ],
    [ :multi_corporation_removal, "Suppression des multi-entreprises", 1, "removal" ],
    [ :multi_coordinator_removal, "Suppression des multi-coordinateurs", 1, "removal" ],
    [ :multi_activity_removal, "Suppression des multi-activités", 1, "removal" ],

    # creation steps
    [ :employers, "Création des employeurs", 8, "addition" ],
    [ :users_operators, "Création des opérateurs", 6, "addition" ],
    [ :students, "Création des élèves", 157, "addition" ],
    [ :users_school_management, "Création des équipes pédagogiques", 42, "addition" ],
    [ :api_offers, "Création des offres API", 10, "addition" ],
    [ :offers, "Création des offres", 30, "addition" ],
    [ :applications, "Création des candidatures", 69, "addition" ],
    [ :agreements, "Création des conventions", 15, "addition" ],
    [ :boarding_houses, "Création des internats", 200, "addition" ]
  ].freeze
  # [:extra_areas, 'Création des espaces supplémentaires - non fait', 0, 'addition'],
  # [:invitation, "Création d'une invitation", 1, 'addition'],
  # [:team, "Création d'une équipe", 1, 'addition'],

  private

  def rebuild_steps_percentages_and_launch_process
    @total ||= STEPS.sum { |step| step[2] }
    @rebuilt_steps_hash = STEPS.each_with_object({}) do |step, hash|
      sym = step[0].to_sym
      text = step[1]
      duration = step[2]
      time_value = @total.zero? ? 0 : (duration.to_f / @total * 100).round(2)
      hash[sym] = { text => time_value }
    end
  end

  # ------------
  # main logic of the rebuild process
  # ------------
  def launch_rebuild_process
    catch(:abort) do
      broadcast_header("Suppression des données")
      remove_steps

      broadcast_header("Création des données")
      creation_steps

      broadcast_header("✅ THAT'S ALL FOLKS")
    end
  rescue StandardError => e
    broadcast_error("🚨 Une erreur est survenue : #{e.message}")
    raise e
  end

  def remove_steps
    broadcast_info(:boarding_house_views_removal)
    BoardingHouseView.delete_all if defined?(BoardingHouseView)

    broadcast_info(:mail_action_item_removal)
    MailActionItem.delete_all if defined?(MailActionItem)

    broadcast_info(:invitation_removal)
    Invitation.where.not(sent_at: nil).delete_all

    broadcast_info(:favorites_removal)
    Favorite.delete_all

    broadcast_info(:student_search_history_removal)
    UsersSearchHistory.delete_all
    UsersInternshipOffersHistory.delete_all

    broadcast_info(:student_removal)
    student_ids = Users::Student.select(:id)
    app_ids = InternshipApplication.where(user_id: student_ids).select(:id)
    agreement_ids = InternshipAgreement.where(internship_application_id: app_ids).select(:id)

    # Supprimer les signatures d'abord (FK vers internship_agreements)
    Signature.where(internship_agreement_id: agreement_ids).delete_all
    # Supprimer les corporation_internship_agreements (FK vers internship_agreements)
    CorporationInternshipAgreement.where(internship_agreement_id: agreement_ids).delete_all
    # Supprimer les internship_application_weeks (FK vers internship_applications)
    InternshipApplicationWeek.where(internship_application_id: app_ids).delete_all
    # Supprimer les conventions (FK vers internship_applications)
    InternshipAgreement.where(internship_application_id: app_ids).delete_all
    # Supprimer les candidatures (FK vers users)
    InternshipApplication.where(user_id: student_ids).delete_all
    # Supprimer les url_shrinkers des étudiants
    UrlShrinker.where(user_id: student_ids).delete_all
    # Supprimer les étudiants
    Users::Student.delete_all

    broadcast_info(:waiting_list_entries_removal)
    WaitingListEntry.delete_all

    broadcast_info(:team_removal)
    TeamMemberInvitation.delete_all

    broadcast_info(:stepper_classes_removal)
    Entreprise.destroy_all
    InternshipOccupation.destroy_all

    broadcast_info(:api_offers_removal)
    InternshipOffers::Api.destroy_all

    broadcast_info(:local_offers_removal)
    InternshipOffer.where.not(type: InternshipOffers::Api.name).destroy_all

    broadcast_info(:notifications_removal)
    AreaNotification.delete_all

    broadcast_info(:user_area_removal)
    User.where.not(current_area_id: nil).update_all(current_area_id: nil)

    broadcast_info(:areas_removal)
    InternshipOffer.destroy_all
    InternshipOfferArea.delete_all


    broadcast_info(:corporation_removal)
    Corporation.destroy_all

    broadcast_info(:multi_corporation_removal)
    MultiCorporation.destroy_all

    broadcast_info(:multi_coordinator_removal)
    MultiCoordinator.destroy_all

    broadcast_info(:multi_activity_removal)
    MultiActivity.destroy_all

    broadcast_info(:employers_removal)
    employer_ids = Users::Employer.select(:id)
    UrlShrinker.where(user_id: employer_ids).delete_all
    Users::Employer.delete_all

    broadcast_info(:users_operator_removal)
    Users::Operator.destroy_all

    broadcast_info(:users_school_management_removal)
    Users::SchoolManagement.destroy_all
  end

  def creation_steps
    addition_steps = STEPS.select { |step| step[3] == "addition" }
    addition_steps.each do |step|
      # show_time do
      broadcast_temporary_info(step[0])
      send("create_#{step[0]}".to_sym)
      broadcast_info(step[0].to_sym)
      # end
    end
  end

  # ------------
  # generic broadcasting methods

  def broadcast_info(sym)
    text = steps_input_text(sym)
    time_value = @rebuilt_steps_hash[sym].values.first
    puts "================================"
    puts "text : #{text}"
    puts "time_value : #{time_value}"
    puts "================================"
    puts ""
    message_box.broadcast_info(message_content: text, time_value: time_value)
  end

  def broadcast_temporary_info(sym)
    text = steps_input_text(sym)
    message_box.broadcast_temporary_info(message_content: text)
  end

  def steps_input_text(sym)
    raise ArgumentError, "Invalid step symbol" unless @rebuilt_steps_hash.key?(sym)

    @rebuilt_steps_hash[sym].keys.first
  end

  def broadcast_error(text)
    message_box.broadcast_error(message_content: text)
    throw(:abort)
  end

  def broadcast_header(text)
    message_box.new_header(text)
  end

  def info(text)
    message_box.broadcast_info(message_content: text, time_value: 0)
  end

  def message_box
    @message_box ||= MessageBox.new(job_id: @job_id)
  end


  # other common methods
  def add_mandatory_attributes(hash)
    hash.merge!(
      password: default_password,
      confirmed_at: Time.current,
      accept_terms: true
    )
  end

  def default_password
    ENV.fetch("DEFAULT_PASSWORD", "password123!!")
  end

  def show_time
    start_time = Time.now
    yield
    end_time = Time.now
    duration = (end_time - start_time) * 10
    tenth_of_seconds = duration.to_i
    message_content = "Étape terminée min en <strong>#{tenth_of_seconds}</strong> dixièmes de seconde"
    message_box.broadcast_info(message_content: message_content, time_value: 0)
  end
end
