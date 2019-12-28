class PreEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pre_enrollment, only: [:destroy]
  require 'date'
  
  def index
    @user = current_user
    @course = @user.coordinator.course.name
    @pre_enrollments = @user.coordinator.pre_enrollments
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
    
    pre_enrollment = ""
    if(params[:id].present?)
      pre_en = PreEnrollment.find(params[:id])
      pre_enrollment = {
        "year" =>  pre_en.year,
        "period" =>  pre_en.period,
        "start_date" =>  pre_en.start_date.to_date,
        "end_date" =>  pre_en.end_date.to_date,
        "disciplines" => pre_en.disciplines_enrollments.map{ |d| d.code }
      };
    end
    @pre_enrollment = pre_enrollment.to_json
  end
  
  def result
    @user = current_user
    @course = @user.coordinator.course.name
    @pre_enrollment = PreEnrollment.find params[:id]
    @disciplines_ob = @pre_enrollment.disciplines_required.sort_by { |x| x.name }
    @disciplines_op = @pre_enrollment.disciplines_optional.sort_by { |x| x.name }
  end
  
  def complete
    @user = current_user
    @result = JSON.parse(params[:data_pre_enrollment])
    ActiveRecord::Base.transaction do
      begin
        if(@result)
          disciplines_enrollments_selected = []
          @preenrollment = PreEnrollment.find_by(year: @result['semester'], period: @result['period'])
          if(!@preenrollment)
            @preenrollment = PreEnrollment.new(year: @result['semester'], period: @result['period'], start_date: Date.parse(@result['start_date']), end_date: Date.parse(@result['end_date']), course: @user.coordinator.course, coordinator: @user.coordinator)
          end
          @result['disciplines'].each do |d|
            discipline = @preenrollment.disciplines_enrollments.find { |x| x.code == d }
            if(discipline)
              disciplines_enrollments_selected << discipline
            else
              disciplines_enrollments_selected << DisciplinesEnrollment.new(code: d)
            end
          end
          @preenrollment.disciplines_enrollments = disciplines_enrollments_selected
          @preenrollment.save!
        end
      rescue ActiveRecord::RecordInvalid => exception
        respond_to do |format|
         format.html { redirect_to pre_enrollments_path, danger: 'Erro ao salvar pré-matrícula, tente novamente.'}
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to pre_enrollments_path, success: 'Pré-Matrícula salva'}
    end
  end

  def destroy
    @pre_enrollment.destroy
    respond_to do |format|
      format.html { redirect_to pre_enrollments_path, success: 'Pré-Matricula excluida.' }
    end
  end
  
  private
    def set_pre_enrollment
      @pre_enrollment = PreEnrollment.find(params[:id])
    end

  
end
