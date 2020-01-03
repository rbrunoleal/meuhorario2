class CreateDisciplineCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :discipline_codes do |t|
      t.string :from_code
      t.string :to_code

      t.timestamps
    end
  end
end
