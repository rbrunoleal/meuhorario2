class CoordinatorsController < ApplicationController
  before_filter :authenticate
  before_action :set_coordinator, only: [:show, :edit, :update, :destroy]

  def index
    @coordinators = Coordinator.all
  end

  def show
  end

  def new
    @coordinator = Coordinator.new
  end

  def edit
  end

  def create
    @coordinator = Coordinator.new(coordinator_params)

    respond_to do |format|
      if @coordinator.save
        format.html { redirect_to @coordinator, notice: 'Criado.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @coordinator.update(coordinator_params)
        format.html { redirect_to @coordinator, notice: 'Atualizado.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @coordinator.destroy
    respond_to do |format|
      format.html { redirect_to coordinators_url, notice: 'Excluido.' }
    end
  end

  private
    def set_coordinator
      @coordinator = Coordinator.find(params[:id])
    end

    def coordinator_params
      params.require(:coordinator).permit(:name, :username, :course_id)
    end
    
  protected
    def authenticate
      if Rails.env.production?
        authenticate_or_request_with_http_basic do |username, password|
          username == ENV["ADMIN_USERNAME"] && password == ENV["ADMIN_PASSWORD"]
        end
      end
    end
end
