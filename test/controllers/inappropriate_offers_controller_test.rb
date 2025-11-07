# frozen_string_literal: true

require 'test_helper'

class InappropriateOffersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  setup do
    @admin = create(:god)
    sign_in(@admin)
    clear_enqueued_jobs
  end

  teardown do
    clear_enqueued_jobs
  end

  def rails_admin_inappropriate_offers_path
    RailsAdmin::Engine.routes.url_helpers.index_path(model_name: 'inappropriate_offer')
  end

  test 'PATCH update_moderation rejects report without notifications' do
    internship_offer = create(:weekly_internship_offer_2nde)
    inappropriate_offer = create(:inappropriate_offer, internship_offer:)

    assert_enqueued_jobs 0 do
      patch update_moderation_inappropriate_offer_path(inappropriate_offer), params: {
        inappropriate_offer: {
          moderation_action: 'rejeter',
          internal_comment: 'Signalement infondé'
        }
      }
    end

    assert_redirected_to rails_admin_inappropriate_offers_path
    inappropriate_offer.reload
    internship_offer.reload

    assert_equal 'rejeter', inappropriate_offer.moderation_action
    assert_equal @admin, inappropriate_offer.moderator
    assert_not_nil inappropriate_offer.decision_date
    assert internship_offer.kept?
    assert_not_nil internship_offer.published_at
  end

  test 'PATCH update_moderation masks offer and notifies employer' do
    internship_offer = create(:weekly_internship_offer_2nde)
    inappropriate_offer = create(:inappropriate_offer, internship_offer:)

    assert_enqueued_jobs 1 do
      patch update_moderation_inappropriate_offer_path(inappropriate_offer), params: {
        inappropriate_offer: {
          moderation_action: 'masquer',
          message_to_offerer: 'Merci de compléter la description.',
          internal_comment: 'Offre masquée pour vérification'
        }
      }
    end

    job = enqueued_jobs.last
    assert_equal ActionMailer::MailDeliveryJob, job[:job]
    assert_equal 'EmployerMailer', job[:args][0]
    assert_equal 'notify_masked_after_moderation', job[:args][1]
   
    assert_redirected_to rails_admin_inappropriate_offers_path

    inappropriate_offer.reload
    internship_offer.reload

    assert_equal 'masquer', inappropriate_offer.moderation_action
    assert_equal @admin, inappropriate_offer.moderator
    assert_nil internship_offer.published_at
    assert internship_offer.kept?
  end

  test 'PATCH update_moderation deletes offer and notifies employer' do
    internship_offer = create(:weekly_internship_offer_2nde)
    inappropriate_offer = create(:inappropriate_offer, internship_offer:)

    assert_enqueued_jobs 1 do
      patch update_moderation_inappropriate_offer_path(inappropriate_offer), params: {
        inappropriate_offer: {
          moderation_action: 'supprimer',
          message_to_offerer: 'Offre supprimée suite à signalement.',
          internal_comment: 'Suppression validée'
        }
      }
    end

    job = enqueued_jobs.last
    assert_equal ActionMailer::MailDeliveryJob, job[:job]
    assert_equal 'EmployerMailer', job[:args][0]
    assert_equal 'notify_deleted_after_moderation', job[:args][1]

    assert_redirected_to rails_admin_inappropriate_offers_path

    inappropriate_offer.reload
    internship_offer.reload

    assert_equal 'supprimer', inappropriate_offer.moderation_action
    assert_equal @admin, inappropriate_offer.moderator
    assert internship_offer.discarded?
  end
end


