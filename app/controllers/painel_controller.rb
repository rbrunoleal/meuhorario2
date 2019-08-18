class PainelController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @user = current_user
    if @user.rule == "student" 
      @student = @user.student 
      if @student.present? 
        if @student.enable? 
          @name_user = @student.name
        else
          redirect_to edit_student_path(@student) 
        end
      end
    else
      @coordinator = @user.coordinator
      if @coordinator.present?
        @name_user = @coordinator.name
      end
    end
  end
  
end
