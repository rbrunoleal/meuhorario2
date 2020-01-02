class PreEnrollment < ApplicationRecord
  belongs_to :course
  belongs_to :coordinator
  
  has_many :disciplines_enrollments, dependent: :destroy
  has_many :record_enrollments, dependent: :destroy
  
  validates_uniqueness_of :year, scope: :period, :message => "Semestre já cadastrado." 
  
  def semester
    return self.year.to_s + "." + self.period.to_s
  end
  
  def available
    @now = Time.current
    return (self.start_date <= @now and self.start_date >= @now) ? false : true
  end
  
  def date_start_format
    return self.start_date.strftime("%d/%m/%Y")
  end
  
  def date_end_format
    return self.end_date.strftime("%d/%m/%Y")
  end
  
  def disciplines_pre_enrollment
    disciplines_select = []
    @course_disciplines = CourseDiscipline.find_by(course: self.course) 
    self.disciplines_enrollments.each do |x|
      @discipline = self.course.disciplines.find { |d| d.code == x.code }
      @course_discipline =  CourseDiscipline.find_by(course: self.course.id, discipline: @discipline.id)
      current_discipline = OpenStruct.new({
        "code" => @discipline.code,
        "name" => @discipline.name,
        "nature" => @course_discipline.nature,
        "quantity" => x.association_quantity,
        "students" => x.record_enrollments.map {|y| [y.student.matricula, y.student.name] }
      });
      disciplines_select << current_discipline
    end
    return disciplines_select
  end
  
  def disciplines_required
    return self.disciplines_pre_enrollment.select { |x| x.nature == "OB" }
  end
  
  def disciplines_optional
    return self.disciplines_pre_enrollment.select { |x| x.nature == "OP" }
  end
end
