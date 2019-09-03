class Department < ApplicationRecord
  has_many :department_courses, dependent: :destroy
  has_many :courses, :through => :department_courses
end
