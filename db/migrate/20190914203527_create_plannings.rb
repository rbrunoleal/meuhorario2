class CreatePlannings < ActiveRecord::Migration[5.0]
  def change
    create_table :plannings do |t|
      t.references :student, foreign_key: true
      t.integer :year
      t.integer :period

      t.timestamps
    end
  end
end
