class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :user_signed_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_authentication
    return if user_signed_in?

    redirect_to sign_in_path, alert: "Войдите в аккаунт, чтобы продолжить."
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
  end

  def redirect_authenticated_user
    redirect_to root_path, notice: "Вы уже вошли в аккаунт." if user_signed_in?
  end
end
