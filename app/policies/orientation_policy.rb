class OrientationPolicy < ApplicationPolicy
  def coordinator?
    user.rule == "coordinator" 
  end
  
  def departments?
    user.rule == "professor" 
  end
  
  def students?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
  
  def new_student?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
  
  def create_student?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
  
  def edit_student?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
  
  def update_student?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
  
  def destroy_student?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
   
  def table_students?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
   
  def complete_students?
    (user.rule == "coordinator" && record.course.id == user.coordinator.course.id) ||
    (user.rule == "professor" && record.professor.id == user.professor_user.id && record.professor.department.institute_department.institute.courses.include?(record.course))
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
