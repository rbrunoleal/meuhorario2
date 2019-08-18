class Coordinator < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :course
  validates :name, :username, presence: true
  validates :username, uniqueness: { message: "Usuário já cadastrado." }
  validates :course_id, uniqueness: { message: "Curso ja cadastrado para um coordenador." }
  
  has_many :pre_enrollments, dependent: :destroy
end
