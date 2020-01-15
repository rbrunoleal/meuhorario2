class AddNameToDisciplinesHistorics < ActiveRecord::Migration[5.0]
  def change
    add_column :disciplines_historics, :name, :string
  end
end
