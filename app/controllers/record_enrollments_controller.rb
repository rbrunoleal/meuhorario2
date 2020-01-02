class RecordEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record_enrollment, only: [:edit, :update, :destroy]
  before_action :set_pre_enrollment, only: [:edit, :new]

  def index
    @user = current_user
    @pre_enrollments_registered = @user.student.record_enrollments.pluck(:pre_enrollment_id)
    @pre_enrollments = @user.student.course.pre_enrollments_available.where.not(id: @pre_enrollments_registered)
    @record_enrollments = @user.student.record_enrollments
    @course = @user.student.course
  end
  
  def load_record
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
    
    @disciplines_pre = []
    @pre_enrollment.disciplines_enrollments.each do |disc|
      discipline = Hash.new
      discipline["id"] = disc.id
      discipline["code"] = disc.code
      @disciplines_pre << discipline
    end
   
    @disciplines_pre_code = []
    @disciplines_pre.each do |disc|
      @disciplines_pre_code << disc['code']
    end
    
    @ops = @ops.select { |x| @disciplines_pre_code.include?(x.code) }
    
   
    @semesters_new = []
    @semesters.each do |x|
      if x.present?
        @semester_array = []
        x.each do |y|
          if(@disciplines_pre_code.include?(y.code))
            @semester_array << y
          end
        end
        @semesters_new << @semester_array
      end
      if x.nil?
        @semesters_new << x
      end
    end
    @semesters = @semesters_new
  end
  
  def new
    @record_enrollment = RecordEnrollment.new
    load_record
  end
  
  def edit
    @record_enrollment_disciplines = @record_enrollment.disciplines_enrollments.map{ |x| x.code }
    load_record
  end
  
   def create
    @record_enrollment = RecordEnrollment.new(record_enrollment_params)
    if current_user.student?
      @record_enrollment.student = current_user.student
    end
    respond_to do |format|
      if @record_enrollment.save
        format.html { redirect_to record_enrollments_path, success: 'Pré-Matricula salva.' }
      else
        format.html { render :new, danger: 'Erro ao salvar pré-Matricula, tente novamente.' } 
      end
    end
  end

  def update
    respond_to do |format|
      if @record_enrollment.update(record_enrollment_params)
        format.html { redirect_to record_enrollments_path, success: 'Pré-Matricula salva.' }
      else
        format.html { render :edit, danger: 'Erro ao salvar pré-Matricula, tente novamente.' } 
      end
    end
  end

  def destroy
    byebug
    @record_enrollment.destroy
    respond_to do |format|
      format.html { redirect_to record_enrollments_path, success: 'Pré-Matricula excluída.' }
    end
  end

  private
    def set_record_enrollment
      @record_enrollment = RecordEnrollment.find(params[:id])
    end
    
    def set_pre_enrollment
      @pre_enrollment = PreEnrollment.find(params[:pre_enrollment_id])
    end
    
    def record_enrollment_params
      params.require(:record_enrollment).permit(:pre_enrollment_id, disciplines_enrollment_ids: [])
    end
end
