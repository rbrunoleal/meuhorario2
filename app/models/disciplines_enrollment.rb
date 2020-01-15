class DisciplinesEnrollment < ApplicationRecord
  belongs_to :pre_enrollment
  
  has_many :association_enrollments, dependent: :destroy
  has_many :record_enrollments, :through => :association_enrollments
  
  def association_quantity
    return self.association_enrollments.count
  end
end
