class StudentsController < ApplicationController
  before_action :set_student, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authorize_student

  def index
    @user = current_user
    @course = @user.coordinator.course.name
    
    @students = Student.order(:name).select { |student| student.course == @user.coordinator.course }
    
    @search = {name: "", matricula: ""}
    if(params.has_key?(:search))
      if params[:matricula_student].present?
        @students = @students.select { |student| student.matricula.include? params[:matricula_student] }
      end
      if params[:name_student].present?
        @students = @students.select { |student| student.name.include? params[:name_student] }
      end
      @search = {name: params[:name_student], matricula: params[:matricula_student]}
    end
  end
  
  def edit
  end
  
  def new
    @student = Student.new
  end
  
  def create
    @user = current_user
    @student = Student.new(student_params)
    respond_to do |format|
      ActiveRecord::Base.transaction do
        begin
          @student.user = @user
          @student.save!
          @user.enable = true
          @user.save!
        rescue ActiveRecord::RecordInvalid => exception
          exception.record.errors.values.each do |ex|
            ex.each do |text|
              flash.now[:danger] = text
            end
          end
          format.html { render :action => 'new' }
        end
      end
      format.html { redirect_to root_path, success: 'Cadastro realizado.'}
    end
  end
  
  def destroy
    ActiveRecord::Base.transaction do
      @user = User.find_by(username: @student.username)
      if @user
        @user.reset
        @user.save
      end
      @student.destroy
    end
    respond_to do |format|
     format.html { redirect_to professor_users_url, success: 'Aluno excluído.' }
    end
  end

  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to students_path }
      else
        format.html { render :edit }
      end
    end
  end

  private
    def authorize_student
      if @student.present?
        authorize @student
      else
        authorize Student
      end
    end
    
    def set_student
      @student = Student.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end

    def student_params
      params.require(:student).permit(:name, :matricula, :email, :course_id)
    end
end
