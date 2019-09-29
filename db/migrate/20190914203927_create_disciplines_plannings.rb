class CreateDisciplinesPlannings < ActiveRecord::Migration[5.0]
  def change
    create_table :disciplines_plannings do |t|
      t.references :planning, foreign_key: true
      t.references :course_discipline, foreign_key: true

      t.timestamps
    end
  end
end
