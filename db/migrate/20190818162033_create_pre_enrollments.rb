class CreatePreEnrollments < ActiveRecord::Migration[5.0]
  def change
    create_table :pre_enrollments do |t|
      t.string :semester
      t.datetime :date_start
      t.datetime :date_end
      t.references :course, foreign_key: true
      t.references :coordinator, foreign_key: true

      t.timestamps
    end
  end
end
