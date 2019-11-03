class CreateDisciplinesPlannings < ActiveRecord::Migration[5.0]
  def change
    create_table :disciplines_plannings do |t|
      t.references :planning, foreign_key: true
      t.string :code
      
      t.timestamps
    end
  end
end
