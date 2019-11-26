class Student < ApplicationRecord
  belongs_to :course
  belongs_to :user
  
  validates :name, presence: { message: "Insira o Nome." }
  validates :course, presence: { message: "Insira o Curso." }
  
  validates :matricula, format: { with: /\A[+-]?\d+\z/, message: "Matrícula e composta por apenas números." }
  validates :matricula, length: { is: 9, message: "Matrícula são necessários 9 digitos." }
  validates :matricula, uniqueness: { message: "Matrícula já cadastrada." }
  
  #validates :email, format: { with: /(\A([a-z]*\s*)*\<*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\>*\Z)/i , message: "E-mail inválido."}
    
  has_many :record_enrollments, dependent: :destroy  
  
  has_many :plannings, dependent: :destroy
  has_many :disciplines_plannings, :through => :plannings
  
  has_many :historics, dependent: :destroy
  has_many :disciplines_historics, :through => :historics
  
  def approved_disciplines
    approved = self.disciplines_historics.select {|x| x.result == 'AP'} 
    return approved.map { |x| x.code }
  end
  
end

