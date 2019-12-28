class CreatePreEnrollments < ActiveRecord::Migration[5.0]
  def change
    create_table :pre_enrollments do |t|
      t.integer :year
      t.integer :period
      t.datetime :start_date
      t.datetime :end_date
      t.references :course, foreign_key: true
      t.references :coordinator, foreign_key: true

      t.timestamps
    end
  end
end
