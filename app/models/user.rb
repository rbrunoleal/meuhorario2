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
  
  def reset
    case self.rule
      when "student"
        self.student.destroy
      when "professor"
        self.professor_user.destroy
      else
        self.coordinator.destroy
    end
    self.rule = 0
    self.enable = false
  end
  
end
