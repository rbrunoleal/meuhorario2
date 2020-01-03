class DisciplineCodesController < ApplicationController
  before_filter :authenticate
  before_action :set_coordinator, only: [:edit, :update, :destroy]

  def index
    @discipline_codes = DisciplineCode.all
  end

  def show
  end

  def new
   @discipline_code = DisciplineCode.new
  end

  def edit
  end

  def create
   @discipline_code = DisciplineCode.new(coordinator_params)
    respond_to do |format|
      if@discipline_code.save
        format.html { redirect_to discipline_codes_path, success: 'Código salvo.' }
      else
        format.html { render :new, danger: 'Erro ao salvar código, tente novamente.' }
      end
    end
  end

  def update
    respond_to do |format|
      if@discipline_code.update(coordinator_params)
        format.html { redirect_to discipline_codes_path, success: 'Código salvo.'}
      else
        format.html { render :edit, danger: 'Erro ao salvar código, tente novamente.' }
      end
    end
  end

  def destroy
    @discipline_code.destroy
    respond_to do |format|
     format.html { redirect_to discipline_codes_path, success: 'Código excluído.' }
    end
  end

  private
    def set_coordinator
     @discipline_code = DisciplineCode.find(params[:id])
     rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end

    def coordinator_params
      params.require(:discipline_code).permit(:from_code, :to_code)
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
