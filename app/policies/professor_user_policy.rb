class ProfessorUserPolicy < ApplicationPolicy
  def index?
    user.rule == "coordinator" 
  end
  
  def new?
    user.rule == "coordinator" 
  end
  
  def create?
    user.rule == "coordinator" 
  end
  
  def table_professors?
    user.rule == "coordinator" 
  end
  
  def complete_professors?
    user.rule == "coordinator" 
  end
  
  def edit?
    user.rule == "coordinator" && record.department.courses.include?(user.coordinator.course)
  end
  
  def update?
    user.rule == "coordinator" && record.department.courses.include?(user.coordinator.course)
  end
  
  def destroy?
    user.rule == "coordinator" && record.department.courses.include?(user.coordinator.course)
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
