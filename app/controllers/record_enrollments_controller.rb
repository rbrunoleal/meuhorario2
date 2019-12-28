class RecordEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record_enrollment, only: [:show, :edit, :update, :destroy]

  def index
    @user = current_user
    @pre_enrollments_registered = @user.student.record_enrollments.pluck(:pre_enrollment_id)
    @pre_enrollments = @user.student.course.pre_enrollments_available.where.not(id: @pre_enrollments_registered)
    @record_enrollments = @user.student.record_enrollments
    @course = @user.student.course
  end
  
   def record
    @user = current_user

    @course = Course.includes(
      course_disciplines: [
        { pre_requisites: [
            { pre_discipline: :discipline },
            { post_discipline: :discipline }
          ],
          post_requisites: [
            { pre_discipline: :discipline },
            { post_discipline: :discipline }
          ]
        },
        :discipline
      ],
      discipline_class_offers: {
        discipline_class: :discipline
      }
    ).find_by_code @user.student.course.code

    cds_all = @course.course_disciplines
    @all_disciplines = cds_all.map {|d| [d.discipline.code, d.discipline.name, d.nature, d.semester.blank? ? 0 : d.semester] }
    
    cds = @course.course_disciplines 

    unless @course.nil?
      @semesters = []
      pre = {}
      post = {}

      cds.reject{ |cd| cd.nature != 'OB' }.each do |cd|
        (@semesters[cd.semester] ||= []) << cd.discipline

        pre_requisites = cd.pre_requisites.reject{ |pre| pre.pre_discipline.nature != 'OB' }
        pre_requisites.each do |p|
          (pre[cd.discipline.code] ||= []) << p.pre_discipline.discipline.code
        end

        post_requisites = cd.post_requisites.reject{ |post| post.post_discipline.nature != 'OB' }
        post_requisites.each do |p|
          (post[cd.discipline.code] ||= []) << p.post_discipline.discipline.code
        end
      end

      @pre  = pre.to_json
      @post = post.to_json
    end

    @ops = cds.reject{ |cd| cd.nature == 'OB' }.map{ |cd| cd.discipline }
   
    record_enrollment = ""
    if(params[:id].present?)
      record_en = RecordEnrollment.find(params[:id])
      record_enrollment = {
        "disciplines" => record_en.disciplines_enrollments.map{ |d| d.code }
      };
    end
    @record_enrollment = record_enrollment.to_json
    
    @disciplines_pre = []
    @pre_enrollment = ""
    if(params[:pre_enrollment_id].present?)
      @pre_enrollment = params[:pre_enrollment_id]
      
      pre_en = PreEnrollment.find(params[:pre_enrollment_id])
      @disciplines_pre = pre_en.disciplines_enrollments.map{ |d| d.code }
      
      @ops = @ops.select { |x| @disciplines_pre.include?(x.code) }
      
      @semester_new = []
      @semesters.each do |x|
        if x.present?
          @semester_disc = []
          x.each do |y|
            if(@disciplines_pre.include?(y.code))
              @semester_disc << y 
            end
          end
          @semester_new << @semester_disc
        end
      end
      @semester = @semester_new
    end
  end
  
  def complete
    @user = current_user
    @result = JSON.parse(params[:data_record_enrollment])
    ActiveRecord::Base.transaction do
      begin
        if(@result)
          @pre_enrollment = PreEnrollment.find(@result['pre_enrollment'])
          @recordenrollment = @user.student.record_enrollments.find{ |r| r.pre_enrollment == @pre_enrollment }
          if(!@recordenrollment)
            @recordenrollment = RecordEnrollment.new(pre_enrollment: @pre_enrollment, student: @user.student)
          end
          association_enrollments_selected = []
          @result['disciplines'].each do |d|
            association_discipline = @recordenrollment.association_enrollments.find { |x| x.disciplines_enrollment.code == d }
            if(association_discipline)
              association_enrollments_selected << association_discipline
            else
              @discipline = DisciplinesEnrollment.find_by(pre_enrollment: @pre_enrollment, code: d)
              association_enrollments_selected << AssociationEnrollment.new(disciplines_enrollment: @discipline)
            end
          end
          @recordenrollment.association_enrollments = association_enrollments_selected
          @recordenrollment.save!
        end
      rescue ActiveRecord::RecordInvalid => exception
        respond_to do |format|
         format.html { redirect_to record_enrollments_path, danger: 'Erro ao salvar pré-matrícula, tente novamente.'}
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to record_enrollments_path, success: 'Pré-Matrícula salva'}
    end
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
