class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string :name
      t.string :matricula
      t.string :email
      t.references :course, foreign_key: true
      t.references :user, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
