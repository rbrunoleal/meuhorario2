class Coordinator < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :course
  
  validates :name, presence: { message: "Insira o Nome." }
  validates :username, presence: { message: "Insira o Usuário." }
  validates :course, presence: { message: "Insira o Curso." }
  
  validates :username, uniqueness: { message: "Usuário já cadastrado." }
  validates :course_id, uniqueness: { message: "Curso ja cadastrado para um coordenador." }
  
  has_many :pre_enrollments, dependent: :destroy
end
