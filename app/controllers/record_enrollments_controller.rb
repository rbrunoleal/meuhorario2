class RecordEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record_enrollment, only: [:edit, :update, :destroy]
  before_action :set_pre_enrollment, only: [:edit, :new]
  before_action :authorize_record_enrollment

  def index
    @user = current_user
    @student = @user.student
    @pre_enrollments_registered = @student.record_enrollments.pluck(:pre_enrollment_id)
    @pre_enrollments = @student.course.pre_enrollments_available.select { |pre_enrollment| not @pre_enrollments_registered.include?(pre_enrollment.id) }
    @record_enrollments = @student.record_enrollments
    @course = @student.course
  end
  
  def load_record
    @user = current_user
    @student = @user.student
    
    @user = current_user
    if !@student.historics.any?
      flash.now[:warning] = "Cadastre seu histórico para uma melhor utilização da pré-matrícula."
    end
    
   
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
    
    @disciplines_historic = @student.approved_disciplines.to_json
    
    cds = @course.course_disciplines 
    cds.each do |x|
      discipline = DisciplineCode.find_by(from_code: x.discipline.code)
      if(discipline)
        x.discipline.code = discipline.to_code
      end
    end
    @all_disciplines = cds.map {|d| [d.discipline.code, d.discipline.name, d.nature, d.semester.blank? ? 0 : d.semester] }

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
    
    @permitted = []
    @historics_disciplines = []
    @pre_disc = @pre_enrollment.disciplines_enrollments.map { |z| z.code }
    @planning = @student.plannings.find { |i| i.year == @pre_enrollment.year && i.period == @pre_enrollment.period }
    if(@planning)
      @historics = @student.approved_disciplines
      @historics.each do |h|
        if h[:semester][:year] < @pre_enrollment.year
          @historics_disciplines.push(h[:code])
        elsif h[:semester][:year] == @pre_enrollment.year && h[:semester][:period] < @pre_enrollment.period
          @historics_disciplines.push(h[:code])
        end
      end
      @planning_disciplines = @planning.disciplines_plannings.map {|c| c.code }
      @planning_disciplines.each do |disc|
        avaible = true        
        if(pre[disc].present?)
          pre[disc].each do |pre_d|
            if !@historics_disciplines.include?(pre_d)
              avaible = false
            end
          end
        end
        if(avaible == true &&  @pre_disc.include?(disc))
          @permitted.push(disc)
        end
      end
    end
    
    @ops = cds.reject{ |cd| cd.nature == 'OB' }.map{ |cd| cd.discipline }
    
    @disciplines_pre = []
    @pre_enrollment.disciplines_enrollments.each do |disc|
      discipline = Hash.new
      discipline["id"] = disc.id
      discipline["code"] = disc.code
      @disciplines_pre << discipline
    end
    
    @disciplines_pre_code = @disciplines_pre.map{ |x| x['code'] }
    
    
    @ops = @ops.select { |x| @disciplines_pre_code.include?(x.code) && !@disciplines_historic.include?(x.code) }
   
    @semesters_new = []
    @semesters.each do |x|
      if x.present?
        @semester_array = []
        x.each do |y|
          if(@disciplines_pre_code.include?(y.code) && !@disciplines_historic.include?(y.code))
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
  
   def update_planning
    @user = current_user
    @student = @user.student
    plannings_student = []
    if record_enrollment_params["disciplines_enrollment_ids"].any?
      @pre_enrollment = PreEnrollment.find(record_enrollment_params["pre_enrollment_id"])
      @code_disciplines = []
      record_enrollment_params["disciplines_enrollment_ids"].each do |disc|
        @disc = DisciplinesEnrollment.find(disc)
        @code_disciplines.push(@disc.code)
      end
      @planning = Planning.find_by year: @pre_enrollment.year, period: @pre_enrollment.period
      if(!@planning)
        @planning = Planning.new(student: @student, year: @pre_enrollment.year, period: @pre_enrollment.period)
      end
      discipline_planning_student =[]
      @code_disciplines.each do |d|
        discipline = @planning.disciplines_plannings.find { |x| x.code == d }
        if(discipline)
          discipline_planning_student << discipline
        else
          discipline_planning_student << DisciplinesPlanning.new(code: d)
        end
      end
      @planning.disciplines_plannings = discipline_planning_student
      @planning.save!
    end
  end
  
  def create
    update_planning
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
    update_planning
    respond_to do |format|
      if @record_enrollment.update(record_enrollment_params)
        format.html { redirect_to record_enrollments_path, success: 'Pré-Matricula salva.' }
      else
        format.html { render :edit, danger: 'Erro ao salvar pré-Matricula, tente novamente.' } 
      end
    end
  end

  def destroy
    @record_enrollment.destroy
    respond_to do |format|
      format.html { redirect_to record_enrollments_path, success: 'Pré-Matricula excluída.' }
    end
  end

  private
    def authorize_record_enrollment
      if @record_enrollment.present?
        authorize @record_enrollment
      else
        authorize RecordEnrollment
      end
    end
  
    def set_record_enrollment
      @record_enrollment = RecordEnrollment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
    
    def set_pre_enrollment
      @pre_enrollment = PreEnrollment.find(params[:pre_enrollment_id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
    
    def record_enrollment_params
      params.require(:record_enrollment).permit(:pre_enrollment_id, disciplines_enrollment_ids: [])
    end
end
