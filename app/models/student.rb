class Student < ApplicationRecord
  belongs_to :course
  belongs_to :user
  
  has_one :orientation
  
  validates :name, presence: { message: "Insira o Nome." }
  validates :course, presence: { message: "Insira o Curso." }
  
  validates :matricula, format: { with: /\A[+-]?\d+\z/, message: "Matrícula e composta por apenas números." }
  validates :matricula, length: { is: 9, message: "Matrícula são necessários 9 digitos." }
  validates :matricula, uniqueness: { message: "Matrícula já cadastrada." }
  
  validates :email, format: { with: /(\A([a-z]*\s*)*\<*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\>*\Z)/i , message: "E-mail inválido."}
    
  has_many :record_enrollments, dependent: :destroy  
  has_many :pre_enrollments, :through => :record_enrollments
  
  has_many :plannings, dependent: :destroy
  has_many :disciplines_plannings, :through => :plannings
  
  has_many :historics, dependent: :destroy
  has_many :disciplines_historics, :through => :historics
  
  def approved_disciplines
    result = []
    results = ["AP", "DI", "DU"];
    approved = self.disciplines_historics.select {|x| results.include?(x.result) } 
    approved.each do |n|
      obj = {
        code: n.code,
        semester: {
          year: n.historic.year,
          period: n.historic.period
        }
      }
      result << obj
    end
    return result
  end
  
end

