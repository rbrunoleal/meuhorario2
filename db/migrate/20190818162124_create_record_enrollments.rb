class CreateRecordEnrollments < ActiveRecord::Migration[5.0]
  def change
    create_table :record_enrollments do |t|
      t.references :pre_enrollment, foreign_key: true
      t.references :student, foreign_key: true

      t.timestamps
    end
  end
end
