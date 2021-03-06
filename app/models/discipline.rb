class Discipline < ApplicationRecord
  has_many :course_disciplines
  has_many :courses, through: :course_disciplines
  has_many :discipline_classes, dependent: :destroy
end
