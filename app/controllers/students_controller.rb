class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:edit, :update]

  def edit
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
