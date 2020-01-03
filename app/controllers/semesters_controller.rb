class SemestersController < ApplicationController
  before_filter :authenticate
  before_action :set_semester, only: [:edit, :update]

  def index
    @semesters = Semester.all
  end

  def edit
  end
  
  def update
    respond_to do |format|
      if @semester.update(semester_params)
        format.html { redirect_to semesters_path, sucess: 'Semestre salvo'}
      else
        format.html { render :edit, danger: 'Erro ao salvar semestre, tente novamente.' }
      end
    end
  end

  private
    def set_semester
      @semester = Semester.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
    
    def semester_params
      params.require(:semester).permit(:year, :period)
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
