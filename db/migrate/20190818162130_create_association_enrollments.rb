class CreateAssociationEnrollments < ActiveRecord::Migration[5.0]
  def change
    create_table :association_enrollments do |t|
      t.references :record_enrollment, foreign_key: true
      t.references :disciplines_enrollment, foreign_key: true

      t.timestamps
    end
  end
end
