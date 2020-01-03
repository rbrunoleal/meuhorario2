class RecordEnrollmentPolicy < ApplicationPolicy
  def index?
    user.rule == "student" && user.enable == true
  end

  def new?
    user.rule == "student" && user.enable == true
  end
  
  def create?
    user.rule == "student" && user.enable == true
  end
  
  def update?
    (user.rule == "student" && user.enable == true) && user.student.record_enrollments.include?(record)
  end
  
  def destroy?
    (user.rule == "student" && user.enable == true) && user.student.record_enrollments.include?(record)
  end
  
  def edit?
    (user.rule == "student" && user.enable == true) && user.student.record_enrollments.include?(record)
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
