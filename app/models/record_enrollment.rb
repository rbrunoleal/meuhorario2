class RecordEnrollment < ApplicationRecord
  belongs_to :pre_enrollment
  belongs_to :student
  
  has_many :association_enrollments, dependent: :destroy
  has_many :disciplines_enrollments, :through => :association_enrollments
end
