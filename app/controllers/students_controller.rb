class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:edit, :update]

  def edit
  end
  
  def new
    @student = Student.new
  end
  
  def create
    @user = current_user
    @student = Student.new(student_params)
    @student.user = @user
    respond_to do |format|
      if @student.save
        @user.enable = true
        if @user.save
          format.html { redirect_to painel_path }
        else
          format.html { render :new }
        end      
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to painel_path }
      else
        format.html { render :edit }
      end
    end
  end

  private
    def set_student
      @student = Student.find(params[:id])
    end

    def student_params
      params.require(:student).permit(:name, :matricula, :course_id)
    end
end
