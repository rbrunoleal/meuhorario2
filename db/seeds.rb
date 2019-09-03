# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

    department_cc = Department.create(name: 'Departamento de Ciência da Computação')
    curso1 = Course.find_by(id: 22)
    curso2 = Course.find_by(id: 31)
    curso3 = Course.find_by(id: 104)
    DepartmentCourse.create(course: curso1, department: department_cc)
    DepartmentCourse.create(course: curso2, department: department_cc)
    DepartmentCourse.create(course: curso3, department: department_cc)
