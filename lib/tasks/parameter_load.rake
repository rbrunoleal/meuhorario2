namespace :parameter_load do
    
    task :disciplines_test => :environment do
      puts '-----------------------------------------------------------------------'
      puts '-> Starting disciplines crawling...' 

      require 'rubygems'
      require 'mechanize'

      ARGV.each { |a| task a.to_sym do ; end }
      ARGV.shift

      codes = []
      ARGV.each do |item|
        codes << item.to_s
      end
      @courses = Course.all.select { |c| codes.include?(c.code) }
      @courses.each do |course|
        puts "    Crawling #{course.name}"
  
        agent = Mechanize.new
        hub = agent.get "https://alunoweb.ufba.br/SiacWWW/CurriculoCursoGradePublico.do?cdCurso=#{course.code}&nuPerCursoInicial=#{course.curriculum}"
  
        for i in 0..1
          page = hub.links[i].click
  
          table = page.search('table')[0]
          rows = table.css('tr')[2..-1]
  
          semester = nil
          next if rows.blank?
          rows.each do |row|
            columns = row.css('td')
  
            semester = columns[0].text.to_i unless columns[0].text.blank?
            nature = columns[1].text
            code = columns[2].text
            name = columns[3].css('a').text.strip
            name = columns[3].text.strip if name == ""
  
            curriculum = nil
            discipline_link = columns[3].css('a')
            if discipline_link.size == 1 && discipline_link.first.attr('href') =~ /nuPerInicial=(\d+)/
              curriculum = $1
            end
  
            discipline = Discipline.find_by_code code
  
            unless discipline
              discipline = Discipline.new
              discipline.code = code
              discipline.name = name
              discipline.curriculum = curriculum
              discipline.save
            end
  
            course_discipline = CourseDiscipline.where(course_id: course.id, discipline_id: discipline.id)
            if course_discipline.blank?
              course_discipline = CourseDiscipline.new
              course_discipline.semester = semester
              course_discipline.nature = nature
              course_discipline.discipline = discipline
              course_discipline.course = course
              course_discipline.save
            end
          end
        end
      end     
      
      puts '-> Finished disciplines crawling'
      puts '-----------------------------------------------------------------------'
    end
    
    desc 'Crawl the disciplines of every known course'
    task :pre_requisites => :environment do
      puts '-----------------------------------------------------------------------'
      puts '-> Starting pre-requisites crawling...'

      require 'rubygems'
      require 'mechanize'

      ARGV.each { |a| task a.to_sym do ; end }
      ARGV.shift

      codes = []
      ARGV.each do |item|
        codes << item.to_s
      end
      @courses = Course.all.select { |c| codes.include?(c.code) }

      @courses.each do |course|
        puts "    Crawling #{course.name}"

        agent = Mechanize.new
        hub = agent.get "https://alunoweb.ufba.br/SiacWWW/CurriculoCursoGradePublico.do?cdCurso=#{course.code}&nuPerCursoInicial=#{course.curriculum}"

        disciplines = []

        for i in 0..1
          page = hub.links[i].click

          table = page.search('table')[0]
          rows = table.css('tr')[2..-1]

          next if rows.blank?
          rows.each do |row|
            columns = row.css('td')

            code = columns[2].text
            disciplines << code
            discipline = Discipline.find_by_code code
            course_discipline = CourseDiscipline.where(course_id: course.id, discipline_id: discipline.id).first

            full_requisites = columns[4].text

            unless full_requisites == '--'
              if full_requisites.include? 'Todas'
                requisites = disciplines - [code]

                if full_requisites.include? 'exceto'
                  non_requisites = full_requisites.split(': ').last.split(', ')
                  requisites -= non_requisites
                end
              else
                requisites = full_requisites.split(', ')
              end

              requisites.each do |requisite|
                pre_discipline = Discipline.find_by_code requisite
                pre_cd = CourseDiscipline.where(course: course, discipline: pre_discipline).first

                if pre_cd.blank?
                  puts "      Código não encontrado: #{requisite} | Disciplina: #{discipline.name} | Curso: #{course.name}"
                elsif pre_cd.semester.nil? or pre_cd.semester != course_discipline.semester
                  pr = PreRequisite.new
                  pr.pre_discipline = pre_cd
                  pr.post_discipline = course_discipline
                  pr.save
                end
              end
            end
          end
        end
      end
      puts '-> Finished pre-requisites crawling'
      puts '-----------------------------------------------------------------------'
    end

    
    task :semester => :environment do
        puts '-----------------------------------------------------------------------'
        puts '-> Starting load semester'
        Semester.create(year: 2020, period: 2)
        puts '-> Finished load semester'
        puts '-----------------------------------------------------------------------'
    end
    
    task :struct_im => :environment do
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
            @discipline = DisciplineCode.find_by(from_code: 'MATE11') 
            if(!@discipline)
                DisciplineCode.create(from_code: "MATE11", to_code: "MATA63")
            end
        puts '-> Finished load discipline code'
        puts '-----------------------------------------------------------------------'
    end
end