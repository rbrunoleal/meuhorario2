class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    @courses = Course.all
    @courses ||= []
  end

  def clear_db
    CourseDiscipline.delete_all
    Discipline.delete_all
    Course.delete_all

    redirect_to root_path
  end

  def crawl_courses
    require 'rubygems'
    require 'mechanize'

    agent = Mechanize.new
    page = agent.get 'https://alunoweb.ufba.br/SiacWWW/ListaCursosEmentaPublico.do?cdGrauCurso=01'

    courseAnchors = page.search('a')

    courseAnchors.each do |a|
      url = a.attribute('href').value

      codeIndex = url.index('cdCurso') + 8
      code = url[codeIndex..codeIndex + 5]

      curriculumIndex = url.index('nuPerCursoInicial') + 18
      curriculum = url[curriculumIndex..curriculumIndex + 4]

      course = Course.find_by_code 'code'
      unless course
        course = Course.new
        course.code = code
        course.name = a.text
        course.curriculum = curriculum
        course.save
      end
    end

    redirect_to root_path
  end

  def crawl_disciplines
    Course.all.each do |course|
      require 'rubygems'
      require 'mechanize'

      agent = Mechanize.new
      page = agent.get "https://alunoweb.ufba.br/SiacWWW/CurriculoCursoGradePublico.do?cdCurso=#{course.code}&nuPerCursoInicial=#{course.curriculum}"
      page = page.links[0].click

      table = page.search('table')[0]
      rows = table.css('tr')[2..-1]

      semester = 1
      rows.each do |row|
        columns = row.css('td')

        semester = columns[0].css('b').text[0].to_i unless columns[0].css('b').text.blank?
        nature = columns[1].text
        code = columns[2].text
        name = columns[3].css('a').text.strip
        requisites = columns[4].text
        requisites = requisites == '--' ? [] : requisites.split(', ')

        discipline = Discipline.find_by_code code

        unless discipline
          discipline = Discipline.new
          discipline.code = code
          discipline.name = name
          discipline.requisites = requisites.join '|'
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

    redirect_to root_path
  end
end
