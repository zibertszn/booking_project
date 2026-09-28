class SessionsController < ApplicationController
  before_action :redirect_authenticated_user, only: %i[new create]

  def new
  end

  def create
    user = User.find_by(email: params.dig(:session, :email).to_s.strip.downcase)

    if user&.authenticate(params.dig(:session, :password).to_s)
      sign_in(user)
      redirect_to root_path, notice: "Вы вошли в аккаунт."
    else
      flash.now[:alert] = "Неверный email или пароль."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to sign_in_path, notice: "Вы вышли из аккаунта."
  end
end