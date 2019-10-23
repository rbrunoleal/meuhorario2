class CreateDisciplinesHistorics < ActiveRecord::Migration[5.0]
  def change
    create_table :disciplines_historics do |t|
      t.string :code
      t.integer :workload
      t.integer :credits
      t.decimal :note
      t.string :result
      t.references :historic, foreign_key: true

      t.timestamps
    end
  end
end
