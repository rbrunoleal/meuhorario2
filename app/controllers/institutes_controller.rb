class InstitutesController < ApplicationController
  before_filter :authenticate
  before_action :set_institute, only: [:edit, :update, :destroy]

  def index
    @institutes = Institute.order(:name)   
    @departments = Department.order(:name)

    @search = {name: ""}
    if(params.has_key?(:search))
      if params[:institute_name].present?
        @institutes = @institutes.select { |institute| institute.name.downcase.include? params[:institute_name].downcase }
      end
    end    
  end

  def new
    @institute = Institute.new
    @departments = Department.order(:name)
  end

  def edit
    @departments = Department.order(:name)
  end

  def create
    @institute = Institute.new(institute_params)
    respond_to do |format|
      if @institute.save
        format.html { redirect_to institutes_path, success: 'Departamento salvo.' }
      else
        format.html { render :new, danger: 'Erro ao salvar departamento, tente novamente.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @institute.update(institute_params)
        format.html { redirect_to institutes_path, success: 'Departamento salvo.'}
      else
        format.html { render :edit, danger: 'Erro ao salvar departamento, tente novamente.' }
      end
    end
  end

  def destroy
    @institute.destroy    
    respond_to do |format|
     format.html { redirect_to institutes_path, success: 'Departamento excluído.' }
    end
  end

  private
    def set_institute
      @institute = Institute.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end

    def institute_params
      params.require(:institute).permit(:name, department_ids: [])
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
