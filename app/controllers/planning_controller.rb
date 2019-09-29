class PlanningController < ApplicationController
  before_action :authenticate_user!
  
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
      @all_disciplines = cds.map {|d| [d.discipline.code, d.discipline.name, d.nature] }
      @params = (@user.student.plannings.map do |p|
        {
          :semester => { year: p.year, period: p.period },
          :disciplines => p.disciplines_plannings.map{ |x| x.course_discipline.discipline.code }
        }
      end).to_json
    end

    @ops = cds.reject{ |cd| cd.nature == 'OB' }.map{ |cd| cd.discipline }
  end
  
  def complete
    @student = current_user.student
    plannings_student = []
    @result = JSON.parse(params[:data_semesters])
    
    ActiveRecord::Base.transaction do
      begin
        @result.each do |r|
          @planning = Planning.find_by(student: @student, year: r['semester']['year'], period: r['semester']['period'])
          if(!@planning)
            @planning = Planning.new(student: @student, year: r['semester']['year'], period: r['semester']['period'])
          end
          discipline_planning_student =[]
          r['disciplines'].each do |d|
            discipline = @planning.disciplines_plannings.find { |x| x.course_discipline.discipline.code == d }
            if(discipline)
              discipline_planning_student << discipline
            else
              @discipline = Discipline.find_by(code: d)
              @course_discipline = CourseDiscipline.find_by(course: @student.course.id, discipline: @discipline.id)
              discipline_planning_student << DisciplinesPlanning.new(course_discipline: @course_discipline)
            end
          end
          @planning.disciplines_plannings = discipline_planning_student
          plannings_student << @planning
        end
        @student.plannings = plannings_student
        @student.save!
      rescue ActiveRecord::RecordInvalid => exception
        respond_to do |format|
         format.html { redirect_to painel_path, notice: 'Erro ao atualizar planejamento, '+ exception.message + ' Tente novamente.'}
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to painel_path}
    end
  end

end
