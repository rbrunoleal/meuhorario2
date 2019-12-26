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
    if self.student
      self.student.destroy
    end
    self.student = nil
    self.coordinator = nil
    self.professor_user = nil
    self.rule = 0
    self.enable = false
  end
  
end
