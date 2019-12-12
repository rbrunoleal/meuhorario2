class ProfessorUser < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :department
  
  validates :name, presence: { message: "Por favor insira o Nome." }
  validates :department, presence: { message: "Por favor insira o Departamento." }
  validates :username, uniqueness: { message: "Usuário já cadastrado." }
  
  has_many :orientations, dependent: :destroy
end
