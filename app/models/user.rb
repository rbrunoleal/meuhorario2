class User < ApplicationRecord
  devise :cas_authenticatable, :trackable, :lockable
         
         
  enum rule: {
    student: 0,
    professor: 1,
    coordinator: 2
  }
  
  def rule_name
    return case self.rule
    when 1
      "Aluno"
    when 2
      "Professor"
    else
      "Coordenador"
    end
  end
  
end
