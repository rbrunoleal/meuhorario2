class CreateCoordinators < ActiveRecord::Migration[5.0]
  def change
    create_table :coordinators do |t|
      t.string :name
      t.string :username
      t.references :course, index: { unique: true }, foreign_key: true
      t.references :user, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
