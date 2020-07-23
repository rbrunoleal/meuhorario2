class Department < ApplicationRecord
  has_many :department_courses, dependent: :destroy
  has_many :courses, :through => :department_courses  

  belongs_to :institute

  has_many :professor_users, dependent: :destroy
end
