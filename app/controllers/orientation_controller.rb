class OrientationController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_orientation, only: [:students, :new_student, :create_student, :edit_student, :update_student, :destroy_student, :table_students, :complete_students]
  before_action :set_course, only: [:students,:create_student, :complete_students]
  before_action :set_professor, only: [:create_student, :complete_students]
  before_action :set_orientation, only: [:edit_student, :update_student, :destroy_student]
  
  
  def coordinator
    @user = current_user
    @professor_users = ProfessorUser.order(:name).select { |professor| professor.department.courses.include?(@user.coordinator.course) }
    @department = @user.coordinator.course.department_course.department.name
  end
  
  def department
    @user = current_user 
    @professor = @user.professor_user
    @courses = @professor.department.courses
    @department = @professor.department
  end
  
  def students
    @orientation_result = [];
    @orientations = @professor.orientations.select { |x| x.course == @course }
    @orientations.each do |o|
      @student = Student.find_by(matricula: o.matricula)
      obj = OpenStruct.new({
        id: o.id,
        name: o.name,
        matricula: o.matricula,
        email: (@student.present?) ? @student.email : "-",
        record: (@student.present?) ? "Realizado" : "Pendente",
        planning: (@student.present?) ? (@student.plannings.present?) ? @student.id : "" : "",
        historic: (@student.present?) ? (@student.historics.present?) ? @student.id : "" : "",
      })
      @orientation_result << obj
    end
  end
  
  def new_student
    @orientation = Orientation.new
  end
  
  def edit_student
  end
  
  def create_student
    @orientation = Orientation.new(student_params)
    @orientation.professor_user = @professor
    @orientation.course = @course
    respond_to do |format|
      if @orientation.save
        format.html { redirect_to orientations_path(params[:professor_id]), success: 'Aluno salvo.' }
      else
        format.html { render :new_student, danger: 'Erro ao salvar aluno, tente novamente.'  }
      end
    end
  end

  def update_student
    respond_to do |format|
      if @orientation.update(student_params)
        format.html { redirect_to orientations_path(:professor_id => @orientation.professor_user.id), success: 'Aluno salvo.' }
      else
        format.html { render :edit_student, danger: 'Erro ao salvar aluno, tente novamente.' }
      end
    end
  end
  
  def destroy_student
    @orientation.destroy
    respond_to do |format|
      format.html { redirect_to orientations_path(:professor_id => params[:professor_id]), success: 'Aluno excluído.' }
    end
  end
  
  def table_students
    @professor = ProfessorUser.find(params[:professor_id])
    @course = Course.find(params[:course_id])
  end
  
  def complete_students
    @result =  JSON.parse(params[:data_orientations])
    ActiveRecord::Base.transaction do
      begin
        if(@result)
          @result.each do |r|
            @orientation = @professor.orientations.find {|x| x.matricula == r['matricula']} 
            if(!@orientation)
              @orientation = Orientation.new(name: r['name'], matricula: r['matricula'])
              @orientation.course = @course
              @professor.orientations << @orientation
            end
          end
          @professor.save!
        end
        respond_to do |format|
          format.html { redirect_to orientations_path, success: 'Alunos cadastrados.'}      
        end
      rescue ActiveRecord::RecordInvalid => exception
        respond_to do |format|
          format.html { redirect_to orientations_path, danger: 'Erro ao salvar alunos, tente novamente.' }
        end
      end
    end
  end
  
  def planning_student
    @student = Student.find(params[:orientation_id])
    
    
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
    ).find_by_code @student.course.code
 
    @disciplines_historic = @student.approved_disciplines.to_json
    
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
      @plannings = (@student.plannings.map do |p|
      {
        :semester => { year: p.year, period: p.period },
        :disciplines => p.disciplines_plannings.map{ |x| x.code }
      }
      end).to_json
    end

    @ops = cds.reject{ |cd| cd.nature == 'OB' }.map{ |cd| cd.discipline }
  end
  
  def historic_student
    @historic = load_historic
  end
  
  def load_historic
    @student = Student.find(params[:orientation_id])
    
    historic_student=[]
    if(@student.historics)
      @student.historics.each do |h|  
        current_historic_disciplines = []
        h.disciplines_historics.each do |d|
          discipline = Discipline.find_by(code: d.code)
          if discipline
            name_discipline = discipline.name
            code_discipline = discipline.code
            course_discipline = CourseDiscipline.find_by(course: @student.course.id, discipline: discipline.id)
            if course_discipline
              nt_discipline = course_discipline.nature
            end
          else
            name_discipline = d.name.blank? ? '' : d.name
            nt_discipline = d.nt.blank? ? '--' : d.nt
            code_discipline = d.code
          end
            current_discipline = {
              code: code_discipline,
              name: name_discipline,
              curricular_component: code_discipline + ' - ' + name_discipline,
              nt: nt_discipline,
              ch: d.workload,
              cr: d.credits,
              note: d.result == 'DI' ? '--' : d.note.to_s,
              res: d.result
            }
            current_historic_disciplines << current_discipline
        end
        current_historic = {
          semester: h.year.to_s + "." + h.period.to_s,
          disciplines_historic: current_historic_disciplines
        }
        historic_student << current_historic
      end
    end
    return historic_student.to_json
  end
  
  private
    def authorize_orientation
      @professor = ProfessorUser.find(params[:professor_id])
      @course = Course.find(params[:course_id])
      @object = OpenStruct.new({
        course: @course,
        professor: @professor
      })
      authorize @object, policy_class: OrientationPolicy
    end
    
    def set_course
      @course = Course.find(params[:course_id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
  
    def set_professor
      @professor = ProfessorUser.find(params[:professor_id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
  
    def set_orientation
      @orientation = Orientation.find(params[:orientation_id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'index'
    end
    
    def student_params
      params.require(:orientation).permit(:name, :matricula)
    end
end
