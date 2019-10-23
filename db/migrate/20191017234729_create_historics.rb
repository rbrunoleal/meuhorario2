class CreateHistorics < ActiveRecord::Migration[5.0]
  def change
    create_table :historics do |t|
      t.integer :year
      t.integer :period
      t.references :student, foreign_key: true

      t.timestamps
    end
  end
end
