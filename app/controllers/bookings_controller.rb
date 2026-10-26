class BookingsController < ApplicationController
  before_action :require_authentication
  before_action :set_booking, only: :destroy
  before_action :ensure_booking_owner, only: :destroy

  def index
    @bookings = current_user.bookings.includes(:resource).order(starts_at: :desc)
  end

  def create
    @resource = Resource.find(booking_params[:resource_id])
    @booking = current_user.bookings.new(booking_params.except(:resource_id))
    @booking.resource = @resource

    if @booking.save
      redirect_to my_bookings_path, notice: "Бронирование успешно создано."
    else
      flash.now[:alert] = "Не удалось создать бронирование."
      render "resources/show", status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @booking.errors.add(:base, "Это время уже занято.")
    flash.now[:alert] = "Это время уже занято."
    render "resources/show", status: :unprocessable_entity
  end

  def destroy
    @booking.destroy!
    redirect_to my_bookings_path, notice: "Бронирование отменено."
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def ensure_booking_owner
    return if @booking.user_id == current_user.id

    redirect_to my_bookings_path, alert: "Вы можете отменять только свои бронирования."
  end

  def booking_params
    params.require(:booking).permit(:resource_id, :starts_at, :ends_at)
  end
end