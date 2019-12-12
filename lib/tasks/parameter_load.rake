namespace :parameter_load do
    
    task :semester => :environment do
        Semester.create(year: 2019, period: 2)
    end
    
    task :departments => :environment do
        @department = Department.create(name: 'Departamento de Ciência da Computação')
        DepartmentCourse.create(department_id: @department.id, course_id: 22)
    end
end