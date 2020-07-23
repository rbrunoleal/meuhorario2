class AddInstituteToDepartments < ActiveRecord::Migration[5.0]
  def change
    add_reference :departments, :institute, foreign_key: true
  end
end
