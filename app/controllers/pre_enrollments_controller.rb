class PreEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pre_enrollment, only: [:edit, :update, :result,:destroy]
  before_action :authorize_pre_enrollment
 
  def index
    @user = current_user
    @course = @user.coordinator.course.name
    @pre_enrollments = @user.coordinator.pre_enrollments
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
    ).find_by_code @user.coordinator.course.code

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
    @obs = cds.reject{ |cd| cd.nature == 'OP' }.map{ |cd| cd.discipline.code }
  end

  def edit
    load_record
    
    @pre_enrollment_discipline = @pre_enrollment.disciplines_enrollments.map { |x| x.code }
  end
  
  def new
    @pre_enrollment = PreEnrollment.new
    @pre_enrollment_discipline = []
    load_record
  end
  
  def result
    @user = current_user
    @course = @user.coordinator.course.name
    @pre_enrollment = PreEnrollment.find params[:id]
    @disciplines_ob = @pre_enrollment.disciplines_required.sort_by { |x| x.name }
    @disciplines_op = @pre_enrollment.disciplines_optional.sort_by { |x| x.name }
  end
   
  def create
    ActiveRecord::Base.transaction do
      begin
        @user = current_user
        @pre_enrollment = PreEnrollment.new(pre_enrollment_params)
        @pre_enrollment.course = @user.coordinator.course
        @pre_enrollment.coordinator = @user.coordinator
        @disciplines = disciplines_params
        @disciplines.each do |d|
          @pre_enrollment.disciplines_enrollments << DisciplinesEnrollment.new(code: d)
        end
        @pre_enrollment.save!
        respond_to do |format|
          format.html { redirect_to pre_enrollments_path, success: 'Pré-Matricula salva.' }
        end
      rescue ActiveRecord::RecordInvalid
        ex_value = []
        if @pre_enrollment.errors.any? 
           @pre_enrollment.errors.values.each do |msg| 
            msg.each do |ex| 
               ex_value << ex 
             end 
           end 
        end 
        respond_to do |format|
         format.html { redirect_to pre_enrollments_path, danger: ex_value.join(', ')}
        end
      end
    end
  end

  def update
      ActiveRecord::Base.transaction do
      begin
        @pre_enrollment.update(pre_enrollment_params)
        @disciplines = disciplines_params
        @disciplines.each do |d|
          @discipline = @pre_enrollment.disciplines_enrollments.find { |x| x.code == d }
          if(!@discipline)
            @pre_enrollment.disciplines_enrollments << DisciplinesEnrollment.new(code: d)
          end
        end
        @pre_enrollment.save!
        respond_to do |format|
           format.html { redirect_to pre_enrollments_path, success: 'Pré-Matricula salva.' }
        end
      rescue ActiveRecord::RecordInvalid
          ex_value = []
          if @pre_enrollment.errors.any? 
             @pre_enrollment.errors.values.each do |msg| 
              msg.each do |ex| 
                 ex_value << ex 
               end 
             end 
          end 
        respond_to do |format|
           format.html { redirect_to pre_enrollments_path, danger: ex_value.join(', ')}
        end
      end
    end
  end
    
  
  def destroy
    @pre_enrollment.destroy
    respond_to do |format|
      format.html { redirect_to pre_enrollments_path, success: 'Pré-Matricula excluida.' }
    end
  end
  
  private
    def authorize_pre_enrollment
      if @pre_enrollment.present?
        authorize @pre_enrollment
      else
        authorize PreEnrollment
      end
    end
    
    def set_pre_enrollment
      @pre_enrollment = PreEnrollment.find(params[:id])
    end
    
    def pre_enrollment_params
      params.require(:pre_enrollment).permit(:year, :period, :start_date, :end_date)
    end
    
    def disciplines_params
      params.require(:pre_enrollment)['disciplines_enrollment']
    end
end
