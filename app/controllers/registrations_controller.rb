class RegistrationsController < ApplicationController
  before_action :redirect_authenticated_user, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      sign_in(@user)
      redirect_to root_path, notice: "Регистрация успешно завершена."
    else
      flash.now[:alert] = "Проверьте поля формы."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end