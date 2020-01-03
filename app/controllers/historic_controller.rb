class HistoricController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_historic, only: [:record, :complete]
  
  def record
    @student = current_user.student
    if !@student.historics.any?
      flash.now[:info] = "Atualize seu histórico."
    end
    @historic = load_historic
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
                discipline = @historic.disciplines_historics.find { |x| x.code == d['code'] }
                if(discipline)
                  discipline_historic_student << discipline
                else
                  discipline_code = DisciplineCode.find_by(to_code: d['code'])
                  if(discipline_code)
                    code_verify = discipline_code.from_code
                  else
                    code_verify = d['code']
                  end
                  discipline_record = Discipline.find_by(code: code_verify)
                  if discipline_record
                    discipline_historic_student << DisciplinesHistoric.new(
                    code: code_verify,
                    workload: d['ch'] == '--' ? 0 : d['ch'],
                    credits: d['cr'] == '--' ? 0 : d['cr'],
                    note: d['note'] == '--' ? 0 : d['note'],
                    result: d['res'])
                  end
                end
              end
              @historic.disciplines_historics = discipline_historic_student
              historic_student << @historic
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
            course_discipline = CourseDiscipline.find_by(course: @student.course.id, discipline: discipline.id)
            if course_discipline
              nt = course_discipline.nature
            else
              nt = '-'
            end
            current_discipline = {
            code: discipline.code,
            name: discipline.name,
            curricular_component: discipline.code + ' - ' + discipline.name,
            nt: nt,
            ch: d.workload,
            cr: d.credits,
            note: d.note.to_s,
            res: d.result
            }
            current_historic_disciplines << current_discipline
          end
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
