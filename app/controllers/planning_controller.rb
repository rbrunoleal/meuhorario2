class PlanningController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_planning, only: [:record, :complete]
  
  def record
    @user = current_user
    if !@user.student.historics.any?
      flash.now[:warning] = "Cadastre seu histórico para uma melhor utilização do planejamento."
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
 
    @disciplines_historic = @user.student.approved_disciplines.to_json
    
    cds = @course.course_disciplines 
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
      @planning = (@user.student.plannings.map do |p|
      {
        :semester => { year: p.year, period: p.period },
        :disciplines => p.disciplines_plannings.map{ |x| x.code }
      }
      end).to_json
    end

    @ops = cds.reject{ |cd| cd.nature == 'OB' }.map{ |cd| cd.discipline }
    @student = @user.student
  end
  
  def complete
    @student = current_user.student
    @result = JSON.parse(params[:data_planning])
    ActiveRecord::Base.transaction do
      begin
        if(@result)
          plannings_student = []
          @result.each do |r|
            @planning = Planning.find_by(student: @student, year: r['semester']['year'], period: r['semester']['period'])
            if(!@planning)
              @planning = Planning.new(student: @student, year: r['semester']['year'], period: r['semester']['period'])
            end
            discipline_planning_student =[]
            r['disciplines'].each do |d|
              discipline = @planning.disciplines_plannings.find { |x| x.code == d }
              if(discipline)
                discipline_planning_student << discipline
              else
                discipline_planning_student << DisciplinesPlanning.new(code: d)
              end
            end
            @planning.disciplines_plannings = discipline_planning_student
            plannings_student << @planning
          end
          @student.plannings = plannings_student
          @student.save!
        end
      rescue ActiveRecord::RecordInvalid => exception
        respond_to do |format|
         format.html { redirect_to planning_path, danger: 'Erro ao salvar planejamento, tente novamente.'}
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to planning_show_path, success: 'Planejamento salvo'}
    end
  end
  
  def show
    @user = current_user
    @student = @user.student
    planning_student=[]
    @student.plannings.each do |p|
      current_planning_disciplines = []
      p.disciplines_plannings.each do |d|
        discipline = @student.course.disciplines.find { |x| x.code == d.code }
        course_discipline = CourseDiscipline.find_by(course: @student.course.id, discipline: discipline.id)
        current_discipline = {
          code: discipline.code,
          name: discipline.name,
          nature: course_discipline.nature
        }
        current_planning_disciplines << current_discipline
      end
      current_planning = {
        semester: {
          year: p.year,
          period: p.period
        },
        disciplines: current_planning_disciplines
      }
      planning_student << current_planning
    end
    @planning = planning_student
  end
  
  private
    def authorize_planning
      if @planning.present?
        authorize @planning
      else
        authorize Planning
      end
    end

end
