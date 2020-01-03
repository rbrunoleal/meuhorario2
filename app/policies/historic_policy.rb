class HistoricPolicy < ApplicationPolicy
  def record?
    user.rule == "student" && user.enable == true
  end

  def complete?
    user.rule == "student" && user.enable == true
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
