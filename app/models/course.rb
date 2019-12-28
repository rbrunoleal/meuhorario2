class Course < ApplicationRecord
  has_many :course_disciplines
  has_many :course_class_offers, dependent: :destroy
  has_many :disciplines, through: :course_disciplines
  has_many :discipline_class_offers, through: :course_class_offers
  belongs_to :area, optional: true
  
  has_one :department_course, dependent: :destroy
  
  has_many :pre_enrollments
  
  def pre_enrollments_available
    @now = Time.current
    return self.pre_enrollments.where('start_date <= ? and end_date >= ?', @now, @now)
  end
  
  def disciplines_required
    return self.course_disciplines.where(nature: 'OB').sort_by { |e| e.discipline.code }
  end
  
  def disciplines_optional
    return self.course_disciplines.where(nature: 'OP').sort_by { |e| e.discipline.code }
  end
end
