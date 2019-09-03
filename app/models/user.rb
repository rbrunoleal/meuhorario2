class User < ApplicationRecord
  devise :cas_authenticatable, :trackable, :lockable
         
  has_one :student, dependent: :destroy
  has_one :coordinator, dependent: :destroy
  has_one :professor_user, dependent: :destroy
         
  enum rule: {
    student: 0,
    professor: 1,
    coordinator: 2
  }
  
  def name
    return case self.rule
    when "student"
      return self.student.name
    when "professor"
      return self.professor_user.name
    else
      return self.coordinator.name
    end
  end
  
end
