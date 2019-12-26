class CreateProfessorUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :professor_users do |t|
      t.string :name
      t.references :department, foreign_key: true
      t.string :username
      t.references :user, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
