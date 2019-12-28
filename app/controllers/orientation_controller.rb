class OrientationController < ApplicationController
  before_action :authenticate_user!
  before_action :set_orientation, only: [:edit_student, :update_student, :destroy_student]

  def coordinator
    @user = current_user
    @professor_users = ProfessorUser.all.select { |professor| professor.department.courses.include?(@user.coordinator.course) }
    @department = @user.coordinator.course.department_course.department.name
  end
  
  def students
    @orientation_result = [];
    @professor = ProfessorUser.find(params[:professor_id])
    @orientations = @professor.orientations
    @orientations.each do |o|
      @student = Student.find_by(matricula: o.matricula)
      obj = OpenStruct.new({
        name: o.name,
        matricula: o.matricula,
        email: (@student.present?) ? @student.email : "",
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
    @orientation.professor_user = ProfessorUser.find(params[:professor_id])
    respond_to do |format|
      if @orientation.save
        format.html { redirect_to orientations_path(params[:professor_id]) }
      else
        format.html { render :new_student }
      end
    end
  end

  def update_student
    respond_to do |format|
      if @orientation.update(student_params)
        format.html { redirect_to orientations_path(:professor_id => @orientation.professor_user.id) }
      else
        format.html { render :edit_student }
      end
    end
  end
  
  def destroy_student
    @orientation.destroy
    respond_to do |format|
      format.html { redirect_to orientations_path(params[:professor_id]) }
    end
  end
  
  def table_students
    @professor = ProfessorUser.find(params[:professor_id])
  end
  
  def complete_students
    @result =  JSON.parse(params[:data_orientations])
    @professor = ProfessorUser.find(params[:professor_id])
    ActiveRecord::Base.transaction do
      begin
        if(@result)
          @result.each do |r|
            byebug
            @orientation = @professor.orientations.select {|x| x.matricula == r['matricula']} 
            if(!@orientation)
              @orientation = Orientation.new(name: r['name'], matricula: r['matricula']) 
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
    def set_orientation
      @orientation = Orientation.find(params[:orientation_id])
    end
    
    def student_params
      params.require(:orientation).permit(:name, :matricula)
    end
end
