class CreateInstituteDepartments < ActiveRecord::Migration[5.0]
  def change
    create_table :institute_departments do |t|
      t.references :institute, foreign_key: true
      t.references :department, foreign_key: true

      t.timestamps
    end
  end
end
