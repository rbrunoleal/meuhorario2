class AddNtToDisciplinesHistorics < ActiveRecord::Migration[5.0]
  def change
    add_column :disciplines_historics, :nt, :string
  end
end
