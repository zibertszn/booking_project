class ResourcesController < ApplicationController
  before_action :require_authentication, only: %i[new create mine edit update destroy]
  before_action :set_resource, only: %i[show availability edit update destroy]
  before_action :ensure_resource_owner, only: %i[edit update destroy]

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

  def mine
    @resources = current_user.resources.order(created_at: :desc)
  end

  def edit
  end

  def update
    if @resource.update(resource_params)
      redirect_to my_resources_path, notice: "Объявление обновлено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @resources = Resource.where(active: true).order(:name)
  end

  def show
    @booking = Booking.new(resource: @resource)
  end

  def availability
    starts_at = parse_time(params[:starts_at])
    ends_at = parse_time(params[:ends_at])

    if starts_at.blank? || ends_at.blank? || ends_at <= starts_at
      return render json: { available: false, error: "Укажите корректный интервал времени." }, status: :unprocessable_entity
    end

    available = !@resource.bookings.where("starts_at < ? AND ends_at > ?", ends_at, starts_at).exists?
    render json: { available: available, resource_id: @resource.id, starts_at: starts_at, ends_at: ends_at }
  end

  def destroy
    @resource.destroy!
    redirect_to my_resources_path, notice: "Объявление удалено."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to my_resources_path, alert: "Нельзя удалить ресурс, у которого есть бронирования."
  end

  private

  def resource_params
    params.require(:resource).permit(:name, :description, :resource_type, :image)
  end

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def ensure_resource_owner
    return if @resource.user_id == current_user.id

    redirect_to my_resources_path, alert: "Вы можете удалять только свои объявления."
  end

  def parse_time(value)
    Time.zone.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
