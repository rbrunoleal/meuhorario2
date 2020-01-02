namespace :parameter_load do
    
    task :semester => :environment do
        puts '-----------------------------------------------------------------------'
        puts '-> Starting load semester'
        Semester.create(year: 2019, period: 2)
        puts '-> Finished load semester'
        puts '-----------------------------------------------------------------------'
    end
    
    task :departments => :environment do
        puts '-----------------------------------------------------------------------'
        puts '-> Starting load department'
        #Departamento de Ciência da Computação
        @department = Department.find_by(name: 'Departamento de Ciência da Computação') 
        @courses = []
        if(!@department)
            @department = Department.create(name: 'Departamento de Ciência da Computação')    
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
        
        puts '-> Finished load discipline code'
        puts '-----------------------------------------------------------------------'
    end
end