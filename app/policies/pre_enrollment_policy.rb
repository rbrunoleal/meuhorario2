class PreEnrollmentPolicy < ApplicationPolicy
  def index?
    user.rule == "coordinator" 
  end

  def new?
    user.rule == "coordinator" 
  end
  
  def create?
    user.rule == "coordinator" 
  end
  
  def students?
    user.rule == "coordinator" && user.coordinator.pre_enrollments.include?(record) 
  end
  
  def edit?
    user.rule == "coordinator" && user.coordinator.pre_enrollments.include?(record)
  end
  
  def update?
    user.rule == "coordinator" && user.coordinator.pre_enrollments.include?(record)
  end
  
  def result?
    user.rule == "coordinator" && user.coordinator.pre_enrollments.include?(record)
  end
  
  def destroy?
    user.rule == "coordinator" && user.coordinator.pre_enrollments.include?(record)
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
