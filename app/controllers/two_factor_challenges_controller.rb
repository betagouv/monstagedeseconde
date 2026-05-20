class TwoFactorChallengesController < ApplicationController
  PENDING_SESSION_KEY = :pending_2fa_user_id

  before_action :load_pending_user

  def new
    ensure_enrollment_secret!
    render_view
  end

  def create
    ensure_enrollment_secret!

    if @pending_user.verify_otp(params[:otp_code])
      session.delete(PENDING_SESSION_KEY)
      sign_in(@pending_user)
      redirect_to after_sign_in_path_for(@pending_user), notice: 'Connexion réussie.'
    else
      flash.now[:alert] = 'Code invalide ou expiré.'
      render_view(status: :unprocessable_entity)
    end
  end

  private

  def load_pending_user
    @pending_user = User.find_by(id: session[PENDING_SESSION_KEY])
    return if @pending_user

    redirect_to new_user_session_path, alert: 'Session expirée. Veuillez vous reconnecter.'
  end

  def ensure_enrollment_secret!
    return if @pending_user.otp_enrolled?

    @pending_user.assign_new_otp_secret!
  end

  def render_view(status: :ok)
    @enrolling = @pending_user.otp_last_used_at.nil?
    @qr_svg = enrollment_qr_svg if @enrolling
    render :new, status: status
  end

  def enrollment_qr_svg
    RQRCode::QRCode.new(@pending_user.otp_provisioning_uri).as_svg(
      module_size: 4,
      standalone: true,
      use_path: true
    ).html_safe
  end
end
