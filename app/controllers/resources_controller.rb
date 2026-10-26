class ResourcesController < ApplicationController
  before_action :require_authentication, only: %i[new create]

  def new
    @resource = current_user.resources.build
  end

  def create
    @resource = current_user.resources.build(resource_params)

    if @resource.save
      redirect_to @resource, notice: "Ресурс опубликован и доступен для бронирования."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @resources = Resource.where(active: true).order(:name)
  end

  def show
    @resource = Resource.find(params[:id])
    @booking = Booking.new(resource: @resource)
  end

  def availability
    resource = Resource.find(params[:id])
    starts_at = parse_time(params[:starts_at])
    ends_at = parse_time(params[:ends_at])

    if starts_at.blank? || ends_at.blank? || ends_at <= starts_at
      return render json: { available: false, error: "Укажите корректный интервал времени." }, status: :unprocessable_entity
    end

    available = !resource.bookings.where("starts_at < ? AND ends_at > ?", ends_at, starts_at).exists?
    render json: { available: available, resource_id: resource.id, starts_at: starts_at, ends_at: ends_at }
  end

  private

  def resource_params
    params.require(:resource).permit(:name, :description, :resource_type, :image)
  end

  def parse_time(value)
    Time.zone.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
