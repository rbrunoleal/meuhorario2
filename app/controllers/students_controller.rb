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
      params.require(:student).permit(:name, :matricula, :email, :course_id)
    end
end
