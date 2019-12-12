class OrientationController < ApplicationController
  before_action :authenticate_user!

  def record
    #@professor_users = ProfessorUser.find(params[:id])
  end

  def coordinator_record
    @professor_users = ProfessorUser.all
  end
  
  def professor_record
  end
end
