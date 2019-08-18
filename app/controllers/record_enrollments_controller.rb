class RecordEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record_enrollment, only: [:show, :edit, :update, :destroy]

  def index
    @pre_enrollments_registered = current_user.student.record_enrollments.pluck(:pre_enrollment_id)
    @pre_enrollments = current_user.student.course.pre_enrollments_available.where.not(id: @pre_enrollments_registered)
    @record_enrollments = current_user.student.record_enrollments
  end

  def show
    @disciplines = @record_enrollment.disciplines_enrollments
  end

  def new
    @pre_enrollment = PreEnrollment.find(params[:pre_enrollment_id])
    @disciplines_op = @pre_enrollment.disciplines_required
    @disciplines_ob = @pre_enrollment.disciplines_optional
    @record_enrollment = RecordEnrollment.new
  end

  def edit
    @pre_enrollment = @record_enrollment.pre_enrollment
    @disciplines_op = @pre_enrollment.disciplines_required
    @disciplines_ob = @pre_enrollment.disciplines_optional
  end

  def create
    @record_enrollment = RecordEnrollment.new(record_enrollment_params)
    if current_user.student?
      @record_enrollment.student = current_user.student
    end

    respond_to do |format|
      if @record_enrollment.save
        format.html { redirect_to @record_enrollment, notice: 'Registro pré-Matricula criado.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @record_enrollment.update(record_enrollment_params)
        format.html { redirect_to @record_enrollment, notice: 'Registro pré-Matricula atualizado.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @record_enrollment.destroy
    
    respond_to do |format|
      format.html { redirect_to record_enrollments_url, notice: 'Registro pré-Matricula apagado.' }
    end
  end

  private
    def set_record_enrollment
      @record_enrollment = RecordEnrollment.find(params[:id])
    end

    def record_enrollment_params
      params.require(:record_enrollment).permit(:pre_enrollment_id, disciplines_enrollment_ids: [])
    end
end
