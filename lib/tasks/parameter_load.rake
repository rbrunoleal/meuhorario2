namespace :parameter_load do
    
    task :semester => :environment do
        puts '-----------------------------------------------------------------------'
        puts '-> Starting load semester'
        Semester.create(year: 2020, period: 2)
        puts '-> Finished load semester'
        puts '-----------------------------------------------------------------------'
    end
    
    task :departments_im => :environment do
        puts '-----------------------------------------------------------------------'
        puts '-> Starting load institutes'
        #Instituto de Matématica
        @institute_im = Institute.find_by(name: 'Instituto de Matématica') 
        if(!@department)
            @institute_im = Institute.create(name: 'Instituto de Matématica')  
        end        
        puts '-> Finished load institutes'
        puts '-> Starting load department'
        #Departamento de Ciência da Computação
        @department = Department.find_by(name: 'Departamento de Ciência da Computação') 
        @courses = []
        if(!@department)
            @department = Department.create(name: 'Departamento de Ciência da Computação', institute: @institute_im)    
            @courses << Course.find_by(code: '112140') #CC
            @courses << Course.find_by(code: '195140') #SI
            @courses << Course.find_by(code: '196120') #COMP
            @department.courses << @courses
            @department.save
        end
        puts '-> Finished load departments'
        puts '-----------------------------------------------------------------------'
    end
    
    task :discipline_code => :environment do
        puts '-----------------------------------------------------------------------'
        puts '-> Starting load discipline code'
            @discipline = DisciplineCode.find_by(from_code: 'MATE12') 
            if(!@discipline)
                DisciplineCode.create(from_code: "MATE12", to_code: "MATA56")
            end
            @discipline = DisciplineCode.find_by(from_code: 'MATE12') 
            if(!@discipline)
                DisciplineCode.create(from_code: "MATE11", to_code: "MATA63")
            end
        puts '-> Finished load discipline code'
        puts '-----------------------------------------------------------------------'
    end
end