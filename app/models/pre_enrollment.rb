class PreEnrollment < ApplicationRecord
  belongs_to :course
  belongs_to :coordinator
  
  has_many :disciplines_enrollments, dependent: :destroy
  has_many :course_disciplines, :through => :disciplines_enrollments
  def available
    @now = Time.current
    return (self.date_start <= @now and self.date_start >= @now) ? false : true
  end
  def date_start_format
    return self.date_start.strftime("%d/%m/%Y - %H:%M")
  end
  def date_end_format
    return self.date_end.strftime("%d/%m/%Y - %H:%M")
  end
  def disciplines_required
    return self.disciplines_enrollments.select { |x| x.course_discipline.nature == 'OP' }
  end
  def disciplines_optional
    return self.disciplines_enrollments.select { |x| x.course_discipline.nature == 'OB' }
  end
end
