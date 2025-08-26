# frozen_string_literal: true

# Job responsible for rebuilding reviews and broadcasting progress updates.
class RebuildReviewJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(job_id)
    # @message_box = message_box
    @job_id = job_id
    rebuild_steps_percentages
  end

  # Steps can evolve over time by just adding or removing steps
  STEPS = [
    # removal steps
    { invitation_removal: ['Suppression des invitations de personnels pédagogiques', 1] },
    { favorites_removal: ['Suppression des favoris des élèves', 1] },
    { student_removal: ['Suppression des élèves, de leurs candidatures, de leurs conventions, des signatures', 5] },
    { student_search_history_removal: ['Suppression des historiques de recherche des élèves',
                                       2] },
    { waiting_list_entries_removal: ["Suppression des listes d'attente[waiting_list_entries]", 1] },
    { team_removal: ['Suppression des équipes', 1] },
    { stepper_classes_removal: ['Suppression du contenu des tables du stepper', 1] },
    { api_offers_removal: ['Suppression des offres api', 1] },
    { local_offers_removal: ['Suppression des offres locales 1E1S', 1] },
    { employers_removal: ['Suppression des employeurs et de leurs offres', 1] },
    { areas_removal: ['Suppression des espaces', 1] },

    # creation steps
    { employers_creation: ['Création des employeurs', 2] },
    { extra_areas_creation: ['Création des espaces supplémentaires', 1] },
    { offers_creation: ['Création des offres', 2] },
    { students_creation: ['Création des élèves', 2] },
    { applications_creation: ['Création des candidatures', 2] },
    { internship_agreements_creation: ['Création des conventions', 2] },
    { applications_invitation: ["Création d'une invitation", 1] },
    { finalization: ['Finalisation du processus de reconstruction', 0] }
  ]

  private

  def rebuild_steps_percentages
    @total ||= STEPS.sum { |step| step.values[0][1] }
    @rebuilt_steps_hash = STEPS.each_with_object({}) do |step, hash|
      sym = step.keys[0]
      text, percentage = step.values[0]
      time_value = (percentage.to_f / @total.to_f * 100).round(2)
      hash[sym] = { text => time_value }
    end
    launch_rebuild_process
  end

  # ------------
  # main logic of the rebuild process
  # ------------
  def launch_rebuild_process
    catch(:abort) do
      broadcast_header('Suppression des données')
      remove_steps

      broadcast_header('Création des données')
      creation_steps

      broadcast_header("✅ THAT'S ALL FOLKS")
    end
  rescue StandardError => e
    broadcast_error("🚨 Une erreur est survenue : #{e.message}")
    raise e
  end

  def remove_steps
    broadcast_info(:invitation_removal)
    Invitation.where.not(sent_at: nil).destroy_all

    broadcast_info(:team_removal)
    TeamMemberInvitation.destroy_all

    broadcast_info(:waiting_list_entries_removal)
    WaitingListEntry.destroy_all

    broadcast_info(:student_search_history_removal)
    UsersSearchHistory.destroy_all

    broadcast_info(:student_removal)
    Users::Student.destroy_all

    broadcast_info(:api_offers_removal)
    InternshipOffers::Api.destroy_all

    broadcast_info(:employers_removal)
    InternshipOffers::WeeklyFramed.destroy_all

    broadcast_info(:stepper_classes_removal)
    InternshipOccupation.destroy_all

    broadcast_info(:local_offers_removal)
    InternshipOffer.destroy_all

    # broadcast_info(:employers_removal)
    # Users::Employer.delete_all

    # broadcast_info(:areas_removal)
    # InternshipOfferArea.delete_all
  end

  def creation_steps
    broadcast_info(:employers_creation)
    create_employers

    broadcast_info(:extra_areas_creation)
    create_extra_areas

    broadcast_info(:offers_creation)
    create_api_offers
    create_offers

    broadcast_info(:students_creation)
    create_students

    broadcast_info(:applications_creation)
    create_applications

    broadcast_info(:agreements_creation)
    create_agreements

    broadcast_info(:invitation_creation)
    create_invitations

    broadcast_info(:team_creation)
    create_teams

    broadcast_info(:finalization)
  end

  def create_employers
    data_array = [
      # { email: 'theophile.gauthier@example.com',
      #   first_name: 'Théophile',
      #   last_name: 'Gauthier',
      #   phone: '0612345676',
      #   company_name: 'Le marais fleuri - artisan fleuriste',
      #   sector: Sector.find_by(uuid: 's12') },
      # { email: 'employer2@example.com',
      #   first_name: 'Julien',
      #   last_name: 'Potier',
      #   phone: '0612345677',
      #   company_name: 'Tradition culinaire & culture du monde',
      #   sector: Sector.find_by(uuid: 's33') },
      # { email: 'employer3@example.com',
      #   first_name: 'Ahmed',
      #   last_name: 'Moussa',
      #   phone: '0612345678',
      #   company_name: "Bureau d'études CAPRICORNE",
      #   sector: Sector.find_by(uuid: 's2') }
      { email: 'theophile.gauthier@flora-international.com',
        first_name: 'Théophile',
        last_name: 'Gauthier',
        phone: '+330612345676' },
      { email: 'julien.potier@food-culture.com',
        first_name: 'Julien',
        last_name: 'Potier',
        phone: '+330612345677' },
      { email: 'ahmed.moussa@capricorne-acme.com',
        first_name: 'Ahmed',
        last_name: 'Moussa',
        phone: '+330612345678' }
    ]
    data_array.map { |data| add_mandatory_attributes(data) }
    data_array.each do |data|
      Users::Employer.create!(**data)
    end
  end

  def add_mandatory_attributes(hash)
    hash.merge!(
      password: password,
      confirmed_at: Time.current,
      accept_terms: true
    )
  end

  def create_extra_areas
  end

  def create_api_offers
  end

  def create_offers
  end

  def create_students
  end

  def create_applications
  end

  def create_agreements
  end

  def create_invitations
  end

  def create_teams
  end

  def password
    ENV.fetch('DEFAULT_PASSWORD', 'password123!!')
  end

  # ------------

  # generic broadcasting methods

  def broadcast_info(sym)
    raise ArgumentError, 'Invalid step symbol' unless @rebuilt_steps_hash.key?(sym)

    text = @rebuilt_steps_hash[sym].keys.first
    time_value = @rebuilt_steps_hash[sym].values.first

    message_box.broadcast_info(message_content: text, time_value: time_value)
  end

  def broadcast_error(text)
    message_box.broadcast_error(message_content: text)
    throw(:abort)
  end

  def broadcast_header(text)
    message_box.new_header(text)
  end

  def message_box
    @message_box ||= MessageBox.new(job_id: @job_id)
  end
end
