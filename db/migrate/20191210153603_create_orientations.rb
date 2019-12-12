class CreateOrientations < ActiveRecord::Migration[5.0]
  def change
    create_table :orientations do |t|
      t.references :professor_user, foreign_key: true
      t.references :student, foreign_key: true

      t.timestamps
    end
  end
end
