class HistoricController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_historic, only: [:record, :complete]
  
  def record
    @student = current_user.student
    if !@student.historics.any?
      flash.now[:info] = "Atualize seu histórico."
    end
    @historic = load_historic
    @ch = @student.ch
    @ch_ob = @student.ch_ob
    @ch_op = @student.ch_op
    @course = @student.course
  end

  def complete
    @student = current_user.student
    @result = JSON.parse(params[:data_historic])
    respond_to do |format|
      ActiveRecord::Base.transaction do
        begin
          if(@result)
            historic_student = []
            @result.each do |r|
              @historic = Historic.find_by(student: @student, year: r['semester'][0,4], period: r['semester'][5,1])
              if(!@historic)
                @historic = Historic.new(student: @student, year: r['semester'][0,4], period: r['semester'][5,1]) 
              end
              discipline_historic_student =[]
              r['disciplines_historic'].each do |d|
                discipline_code = DisciplineCode.find_by(to_code: d['code'])
                if(discipline_code)
                  code_verify = discipline_code.from_code
                else
                  code_verify = d['code']
                end
                  discipline_historic_student << DisciplinesHistoric.new(
                    code: code_verify,
                    workload: d['ch'] == '--' ? 0 : d['ch'],
                    credits: d['cr'] == '--' ? 0 : d['cr'],
                    note: d['note'] == '--' ? 0 : d['note'],
                    name: d['name'],
                    nt: d['nt'],
                    result: d['res'])
              end
              @historic.disciplines_historics = discipline_historic_student
              if(@historic.disciplines_historics.any?)
                historic_student << @historic
              end
            end
              @student.historics = historic_student
              @student.save!
          end
        rescue ActiveRecord::RecordInvalid => exception
            flash.now[:danger] = 'Erro ao salvar histórico, tente novamente.'
            format.html { render :action => 'record' }
        end
      end
      format.html { redirect_to historic_show_path, success: 'Histórico salvo'}
    end
  end
  
  def show
    @historic = load_historic
  end
  
  def load_historic
    @user = current_user
    @student =  @user.student
    
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
    def authorize_historic
      if @historic.present?
        authorize @historic
      else
        authorize Historic
      end
    end
end
