# frozen_string_literal: true

class InappropriateOffersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_inappropriate_offer, only: [:manage, :update_moderation]

  def manage
  end

  def update_moderation
    if @inappropriate_offer.update(moderation_params)
      handle_moderation_action
      flash[:notice] = 'La modération a été enregistrée avec succès.'
      redirect_to rails_admin.index_path(model_name: 'inappropriate_offer')
    else
      flash.now[:alert] = 'Erreur lors de l\'enregistrement de la modération.'
      render :manage
    end
  end

  private

  def set_inappropriate_offer
    @inappropriate_offer = InappropriateOffer.find(params[:id])
    @internship_offer = @inappropriate_offer.internship_offer
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Signalement introuvable.'
    redirect_to rails_admin.index_path(model_name: 'inappropriate_offer')
  end

  def ensure_admin!
    unless current_user.is_a?(Users::God)
      flash[:alert] = 'Accès non autorisé.'
      redirect_to root_path
    end
  end

  def moderation_params
    params.require(:inappropriate_offer).permit(
      :moderation_action,
      :message_to_offerer,
      :internal_comment
    ).merge(
      decision_date: Time.current,
      moderator_id: current_user.id
    )
  end

  def handle_moderation_action
    case @inappropriate_offer.moderation_action
    when 'rejeter'
      # The report is rejected, the offer remains visible
    when 'masquer'
      # Temporary masked
      @internship_offer.update(published_at: nil) if @internship_offer.published?
      send_notification_masked_employer if @inappropriate_offer.message_to_offerer.present?
    when 'supprimer'
      # Completely removed (soft delete)
      @internship_offer.discard if @internship_offer.kept?
      send_notification_deleted_employer if @inappropriate_offer.message_to_offerer.present?
    end
  end

  def send_notification_masked_employer
    EmployerMailer.notify_masked_after_moderation(internship_offer: @internship_offer, inappropriate_offer: @inappropriate_offer).deliver_later
  end

  def send_notification_deleted_employer
    EmployerMailer.notify_deleted_after_moderation(internship_offer: @internship_offer, inappropriate_offer: @inappropriate_offer).deliver_later
  end
end

