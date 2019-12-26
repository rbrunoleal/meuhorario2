class Orientation < ApplicationRecord
  belongs_to :professor_user
  
  validates :name, presence: { message: "Insira o Nome." }
  validates :matricula, format: { with: /\A[+-]?\d+\z/, message: "Matrícula e composta por apenas números." }
  validates :matricula, length: { is: 9, message: "Matrícula são necessários 9 digitos." }
  validates :matricula, uniqueness: { message: "Matrícula já cadastrada." }
  
end
