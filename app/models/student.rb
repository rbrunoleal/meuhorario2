class Student < ApplicationRecord
  belongs_to :course
  belongs_to :user
  
  has_one :orientation
  
  validates :name, presence: { message: "Insira o Nome." }
  validates :course, presence: { message: "Insira o Curso." }
  
  validates :matricula, format: { with: /\A[+-]?\d+\z/, message: "Matrícula e composta por apenas números." }
  validates :matricula, length: { is: 9, message: "Matrícula são necessários 9 digitos." }
  validates :matricula, uniqueness: { message: "Matrícula já cadastrada." }
  
  validates :email, format: { with: /(\A([a-z]*\s*)*\<*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\>*\Z)/i , message: "E-mail inválido."}
    
  has_many :record_enrollments, dependent: :destroy  
  has_many :pre_enrollments, :through => :record_enrollments
  
  has_many :plannings, dependent: :destroy
  has_many :disciplines_plannings, :through => :plannings
  
  has_many :historics, dependent: :destroy
  has_many :disciplines_historics, :through => :historics
  
  def approved_disciplines
    disciplines = []
    results_permitted = ["AP", "DI", "DU"];
    approved = self.disciplines_historics.select {|x| results_permitted.include?(x.result) } 
    approved.each do |n|
      obj = {
        code: n.code,
        semester: {
          year: n.historic.year,
          period: n.historic.period
        }
      }
      disciplines << obj
    end
    return disciplines
  end
  
  def ch_historic_op
    result = 0
    disciplines = self.disciplines_historics.select {|x| x.workload != '--' && x.nt == 'OP' } 
    workloads = disciplines.map { |x| x.workload } 
    workloads.each do |h|
      result += h.to_i
    end
    return result
  end
  
  def ch_historic_ob
    result = 0
    disciplines = self.disciplines_historics.select {|x| x.workload != '--' && x.nt == 'OB' } 
    workloads = disciplines.map { |x| x.workload } 
    workloads.each do |h|
      result += h.to_i
    end
    return result
  end
  
  def ch_planning_op
    result = 0
    disciplines = self.disciplines_plannings.map { |x| x.code }
    disciplines.each do |c|
      @discipline = Discipline.find_by(code: c)
      if @discipline
        @course_discipline = CourseDiscipline.find_by(course: self.course.id, discipline: @discipline.id)
        if @course_discipline
          if(@course_discipline.nature = 'OP')
            result += @course_discipline.load
          end
        end
      end
    end
    return result
  end
  
  def ch_planning_ob
    result = 0
    disciplines = self.disciplines_plannings.map { |x| x.code }
    disciplines.each do |c|
      @discipline = Discipline.find_by(code: c)
      if @discipline
        @course_discipline = CourseDiscipline.find_by(course: self.course.id, discipline: @discipline.id)
        if @course_discipline
          if(@course_discipline.nature = 'OB')
            result += @course_discipline.load
          end
        end
      end
    end
    return result
  end
  
end

