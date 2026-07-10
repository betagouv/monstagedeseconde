# frozen_string_literal: true

require "test_helper"

module Presenters
  class InternshipApplication
    class HumanStateTest < ActiveSupport::TestCase
      PATH = "/dashboard/students/1/internship_applications/abc"

      def build(state:, role:, previously_progressed: false)
        app = Minitest::Mock.new
        app.expect(:aasm_state, state)
        if state == "restored"
          app.expect(:aasm_state, state)
          app.expect(:has_ever_been?, previously_progressed, [%w[read_by_employer transfered validated_by_employer]])
        end
        HumanState.for(application: app, role: role, application_path: PATH)
      end

      # ── unknown role / state ───────────────────────────────────────────────

      test "raises UnknownRole for unrecognised role" do
        assert_raises(HumanState::UnknownRole) do
          HumanState.for(application: Minitest::Mock.new, role: :god, application_path: PATH)
        end
      end

      test "raises UnknownState for unrecognised state" do
        app = Minitest::Mock.new
        app.expect(:aasm_state, "nonexistent_state")
        app.expect(:aasm_state, "nonexistent_state")
        hs = HumanState.for(application: app, role: :student, application_path: PATH)
        assert_raises(HumanState::UnknownState) { hs.to_h }
      end

      # ── submitted ──────────────────────────────────────────────────────────

      test "submitted · student sees 'Sans réponse'" do
        h = build(state: "submitted", role: :student).to_h
        assert_equal "Sans réponse de l'entreprise", h[:label]
        assert_equal "info", h[:badge]
        assert_equal "Envoyées, en attente de réponse", h[:tab]
        assert_equal "Voir", h[:actions].first[:label]
        assert_equal "tertiary", h[:actions].first[:level]
      end

      test "submitted · school_management sees 'Sans réponse'" do
        h = build(state: "submitted", role: :school_management).to_h
        assert_equal "Sans réponse de l'entreprise", h[:label]
        assert_equal "Répondre", h[:actions].first[:label]
      end

      test "submitted · employer sees 'nouveau'" do
        h = build(state: "submitted", role: :employer).to_h
        assert_equal "nouveau", h[:label]
        assert_equal "Répondre", h[:actions].first[:label]
        assert_equal "primary", h[:actions].first[:level]
      end

      # ── restored ───────────────────────────────────────────────────────────

      test "restored · student always sees 'sans réponse'" do
        h = build(state: "restored", role: :student).to_h
        assert_equal "sans réponse de l'entreprise", h[:label]
        assert_equal "Voir", h[:actions].first[:label]
      end

      test "restored · employer previously progressed sees 'candidature restaurée'" do
        h = build(state: "restored", role: :employer, previously_progressed: true).to_h
        assert_equal "candidature restaurée", h[:label]
        assert_equal "Candidature restaurée - répondre", h[:actions].first[:label]
      end

      test "restored · employer not previously progressed sees 'nouveau'" do
        h = build(state: "restored", role: :employer, previously_progressed: false).to_h
        assert_equal "nouveau", h[:label]
        assert_equal "Répondre", h[:actions].first[:label]
      end

      # ── read_by_employer ───────────────────────────────────────────────────

      test "read_by_employer · student sees 'Sans réponse' with info badge" do
        h = build(state: "read_by_employer", role: :student).to_h
        assert_equal "Sans réponse de l'entreprise", h[:label]
        assert_equal "info", h[:badge]
        assert_equal "Voir", h[:actions].first[:label]
      end

      test "read_by_employer · employer sees 'Lue' with warning badge" do
        h = build(state: "read_by_employer", role: :employer).to_h
        assert_equal "Lue", h[:label]
        assert_equal "warning", h[:badge]
        assert_equal "Répondre", h[:actions].first[:label]
      end

      # ── transfered ─────────────────────────────────────────────────────────

      test "transfered · student sees 'en attente de réponse'" do
        h = build(state: "transfered", role: :student).to_h
        assert_equal "en attente de réponse", h[:label]
        assert_equal "Envoyées, en attente de réponse", h[:tab]
      end

      test "transfered · employer sees 'transféré'" do
        h = build(state: "transfered", role: :employer).to_h
        assert_equal "transféré", h[:label]
        assert_equal "Transférées", h[:tab]
      end

      # ── validated_by_employer ──────────────────────────────────────────────

      test "validated_by_employer · student sees 'acceptée par l'entreprise' with success badge" do
        h = build(state: "validated_by_employer", role: :student).to_h
        assert_equal "acceptée par l'entreprise", h[:label]
        assert_equal "success", h[:badge]
        assert_equal "Répondre", h[:actions].first[:label]
        assert_equal "primary", h[:actions].first[:level]
      end

      test "validated_by_employer · employer sees 'en attente de réponse'" do
        h = build(state: "validated_by_employer", role: :employer).to_h
        assert_equal "en attente de réponse", h[:label]
        assert_equal "info", h[:badge]
        assert_equal "Voir", h[:actions].first[:label]
      end

      # ── canceled_by_employer ───────────────────────────────────────────────

      test "canceled_by_employer · all roles see same label" do
        %i[student school_management employer].each do |role|
          h = build(state: "canceled_by_employer", role: role).to_h
          assert_equal "annulée par l'employeur", h[:label]
          assert_equal "error", h[:badge]
          assert_equal "Annulées", h[:tab]
        end
      end

      # ── rejected ───────────────────────────────────────────────────────────

      test "rejected · all roles see same label" do
        %i[student school_management employer].each do |role|
          h = build(state: "rejected", role: role).to_h
          assert_equal "refusée par l'employeur", h[:label]
          assert_equal "warning", h[:badge]
        end
      end

      # ── canceled_by_student ────────────────────────────────────────────────

      test "canceled_by_student · student sees 'annulée'" do
        h = build(state: "canceled_by_student", role: :student).to_h
        assert_equal "annulée", h[:label]
      end

      test "canceled_by_student · employer sees 'annulée par l'élève'" do
        h = build(state: "canceled_by_student", role: :employer).to_h
        assert_equal "annulée par l'élève", h[:label]
      end

      # ── expired ────────────────────────────────────────────────────────────

      test "expired · all roles see 'expirée'" do
        %i[student school_management employer].each do |role|
          h = build(state: "expired", role: role).to_h
          assert_equal "expirée", h[:label]
          assert_equal "error", h[:badge]
          assert_equal "Expirées", h[:tab]
        end
      end

      # ── expired_by_student ─────────────────────────────────────────────────

      test "expired_by_student · student sees personal message" do
        h = build(state: "expired_by_student", role: :student).to_h
        assert_equal "vous n'avez pas répondu dans les délais", h[:label]
      end

      test "expired_by_student · employer sees third-person message" do
        h = build(state: "expired_by_student", role: :employer).to_h
        assert_equal "l'élève n'a pas répondu dans les délais", h[:label]
      end

      # ── canceled_by_student_confirmation ──────────────────────────────────

      test "canceled_by_student_confirmation · student sees first-person" do
        h = build(state: "canceled_by_student_confirmation", role: :student).to_h
        assert_equal "Vous avez choisi un autre stage", h[:label]
      end

      test "canceled_by_student_confirmation · employer sees third-person" do
        h = build(state: "canceled_by_student_confirmation", role: :employer).to_h
        assert_equal "L'élève a choisi un autre stage", h[:label]
      end

      # ── approved ───────────────────────────────────────────────────────────

      test "approved · student gets contact action" do
        h = build(state: "approved", role: :student).to_h
        assert_equal "stage validé", h[:label]
        assert_equal "success", h[:badge]
        assert_equal "Votre stage validé", h[:tab]
        assert_equal "Contacter l'employeur", h[:actions].first[:label]
        assert_equal "primary", h[:actions].first[:level]
      end

      test "approved · employer gets view action" do
        h = build(state: "approved", role: :employer).to_h
        assert_equal "Stage validé", h[:tab]
        assert_equal "Voir", h[:actions].first[:label]
        assert_equal "secondary", h[:actions].first[:level]
      end

      # ── [] compat ──────────────────────────────────────────────────────────

      test "[] delegates to to_h for view compat" do
        app = Minitest::Mock.new
        app.expect(:aasm_state, "approved")
        app.expect(:aasm_state, "approved")
        hs = HumanState.for(application: app, role: :student, application_path: PATH)
        assert_equal "stage validé", hs[:label]
      end

      # ── action path ────────────────────────────────────────────────────────

      test "actions include the provided application_path" do
        h = build(state: "submitted", role: :student).to_h
        assert_equal PATH, h[:actions].first[:path]
      end
    end
  end
end
