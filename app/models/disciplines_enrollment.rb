class DisciplinesEnrollment < ApplicationRecord
  belongs_to :pre_enrollment
  belongs_to :course_discipline
  
  has_many :association_enrollments
  has_many :record_enrollments, :through => :association_enrollments
  def identifier
    return self.course_discipline.discipline.code + ' - ' + self.course_discipline.discipline.name
  end
  def association_quantity
    return self.association_enrollments.count
  end
end
