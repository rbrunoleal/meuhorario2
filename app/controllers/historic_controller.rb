class HistoricController < ApplicationController
  before_action :authenticate_user!
  
  def record
    @student = current_user.student
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
          semester: h.semester_year.to_s + "." + h.semester_period.to_s,
          disciplines_historic: current_historic_disciplines
        }
        historic_student << current_historic
      end
    end
    @historic  = historic_student.to_json
  end

  def complete
    @student = current_user.student
    @result = JSON.parse(params[:data_historic])
    
    ActiveRecord::Base.transaction do
      begin
        if(@result)
          historic_student = []
          @result.each do |r|
            @historic = Historic.find_by(student: @student, semester_year: r['semester'][0,4], semester_period: r['semester'][5,1]) #mudar
            if(!@historic)
              @historic = Historic.new(student: @student, semester_year: r['semester'][0,4], semester_period: r['semester'][5,1]) #mudar
            end
            discipline_historic_student =[]
            r['disciplines_historic'].each do |d|
              discipline = @historic.disciplines_historics.find { |x| x.code == d['code'] }
              if(discipline)
                discipline_historic_student << discipline
              else
                discipline_historic_student << DisciplinesHistoric.new(
                  code: d['code'],
                  workload: d['ch'] == '--' ? 0 : d['ch'],
                  credits: d['cr'] == '--' ? 0 : d['cr'],
                  note: d['note'] == '--' ? 0 : d['note'],
                  result: d['res']
                )
              end
            end
            @historic.disciplines_historics = discipline_historic_student
            historic_student << @historic
          end
          @student.historics = historic_student
          @student.save!
        end
      rescue ActiveRecord::RecordInvalid => exception
        respond_to do |format|
         format.html { redirect_to planning_path, danger: 'Erro ao salvar histórico, tente novamente.'}
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to painel_path, success: 'Histórico salvo'}
    end
  end
  
end
