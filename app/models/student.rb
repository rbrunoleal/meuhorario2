class Student < ApplicationRecord
  belongs_to :course
  belongs_to :user
  
  validates :name, presence: { message: "Por favor insira o Nome." }
  validates :course, presence: { message: "Por favor insira o Curso." }
  
  validates :matricula, format: { with: /\A[+-]?\d+\z/, message: "Matrícula e composta por apenas números." }
  validates :matricula, length: { is: 9, message: "Matrícula são necessários 9 digitos." }
  validates :matricula, uniqueness: { message: "Matrícula já cadastrada." }
    
  has_many :record_enrollments, dependent: :destroy  
    
  after_validation :enable_student
  
  private
    def enable_student
      self.enable = true
    end
end

