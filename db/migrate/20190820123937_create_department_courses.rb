class CreateDepartmentCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :department_courses do |t|
      t.references :department, foreign_key: true
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
