class StudentPolicy < ApplicationPolicy
  def index?
    user.rule == "coordinator" 
  end
  
  def new?
    user.rule == "student" 
  end
  
  def create?
    user.rule == "student" 
  end
  
  def edit?
    user.rule == "coordinator" && record.course == user.coordinator.course
  end
  
  def update?
    user.rule == "coordinator" && record.course == user.coordinator.course
  end
  
  def destroy?
    user.rule == "coordinator" && record.course == user.coordinator.course
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
