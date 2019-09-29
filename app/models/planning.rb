class Planning < ApplicationRecord
  belongs_to :student
  
  
  has_many :disciplines_plannings, dependent: :destroy
  has_many :course_discipline, :through => :disciplines_plannings
end
