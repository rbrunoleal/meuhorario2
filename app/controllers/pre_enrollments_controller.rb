class PreEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pre_enrollment, only: [:show, :edit, :update, :destroy]

  def index
    @pre_enrollments = current_user.coordinator.pre_enrollments
  end

  def show
    @disciplines = @pre_enrollment.disciplines_enrollments
  end

  def new
    @disciplines_ob = []
    @disciplines_op = []
    @coordinator = current_user.coordinator
    if @coordinator.present?
      @disciplines_ob = @coordinator.course.disciplines_required
      @disciplines_op = @coordinator.course.disciplines_optional
    end
    @pre_enrollment = PreEnrollment.new
  end

  def edit
    @disciplines_ob = []
    @disciplines_op = []
    @coordinator = current_user.coordinator
    if @coordinator.present?
      @disciplines_ob = @coordinator.course.disciplines_required
      @disciplines_op = @coordinator.course.disciplines_optional
    end
  end
  
  def result
    @pre_enrollment = PreEnrollment.find params[:id]
    @disciplines_op = @pre_enrollment.disciplines_required
    @disciplines_ob = @pre_enrollment.disciplines_optional
  end
  
  def detail
    @pre_enrollment = PreEnrollment.find params[:id]
    @disciplines_op = @pre_enrollment.disciplines_required
    @disciplines_ob = @pre_enrollment.disciplines_optional
  end

  def create
    @pre_enrollment = PreEnrollment.new(pre_enrollment_params)
    @user_coordinator = current_user.coordinator
    if @user_coordinator.present?
      @pre_enrollment.coordinator = @user_coordinator
      @pre_enrollment.course = @user_coordinator.course
    end
   
    respond_to do |format|
      if @pre_enrollment.save
        format.html { redirect_to @pre_enrollment, notice: 'Pré-Matricula criada.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @pre_enrollment.update(pre_enrollment_params)
        format.html { redirect_to @pre_enrollment, notice: 'Pré-Matricula atualizada.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @pre_enrollment.destroy
    respond_to do |format|
      format.html { redirect_to pre_enrollments_url, notice: 'Pré-Matricula excluida.' }
    end
  end

  private
    def set_pre_enrollment
      @pre_enrollment = PreEnrollment.find(params[:id])
    end

    def pre_enrollment_params
      params.require(:pre_enrollment).permit(:semester, :date_start, :date_end, course_discipline_ids: [])
    end
end
