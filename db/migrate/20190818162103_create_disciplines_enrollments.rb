class CreateDisciplinesEnrollments < ActiveRecord::Migration[5.0]
  def change
    create_table :disciplines_enrollments do |t|
      t.references :pre_enrollment, foreign_key: true
      t.references :course_discipline, foreign_key: true

      t.timestamps
    end
  end
end
