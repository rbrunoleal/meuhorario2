class OrientationController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_orientation, only: [:students, :new_student, :create_student, :edit_student, :update_student, :destroy_student, :table_students, :complete_students]
  before_action :set_course, only: [:students,:create_student, :complete_students]
  before_action :set_professor, only: [:create_student, :complete_students]
  before_action :set_orientation, only: [:edit_student, :update_student, :destroy_student]
  
  
  def coordinator
    @user = current_user
    @professor_users = ProfessorUser.all.select { |professor| professor.department.courses.include?(@user.coordinator.course) }
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
          discipline = @student.course.disciplines.find { |x| x.code == d.code }
          course_discipline = CourseDiscipline.find_by(course: @student.course.id, discipline: discipline.id)
          current_discipline = {
            code: discipline.code,
            name: discipline.name,
            curricular_component: discipline.code + ' - ' + discipline.name,
            nt: course_discipline.nature,
            ch: d.workload,
            cr: d.credits,
            note: d.note.to_s,
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
