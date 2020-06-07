class DepartmentsController < ApplicationController
  before_filter :authenticate
  before_action :set_department, only: [:edit, :update, :destroy]

  def index
    @departments = Department.order(:name)   
    @courses = Course.order(:name)

    @search = {name: ""}
    if(params.has_key?(:search))
      if params[:department_name].present?
        @departments = @departments.select { |department| department.name.downcase.include? params[:department_name].downcase }
      end
    end    
  end

  def new
    @department = Department.new
    @courses = Course.order(:name)
  end

  def edit
    @courses = Course.order(:name)
  end

  def create
    @department = Department.new(department_params)
    respond_to do |format|
      if @department.save
        format.html { redirect_to departments_path, success: 'Departamento salvo.' }
      else
        format.html { render :new, danger: 'Erro ao salvar departamento, tente novamente.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to departments_path, success: 'Departamento salvo.'}
      else
        format.html { render :edit, danger: 'Erro ao salvar departamento, tente novamente.' }
      end
    end
  end

  def destroy
    @department.destroy    
    respond_to do |format|
     format.html { redirect_to departments_path, success: 'Departamento excluído.' }
    end
  end

  private
    def set_department
      @department = Department.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end

    def department_params
      params.require(:department).permit(:name, course_ids: [])
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
