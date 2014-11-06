class CreateProgrammes < ActiveRecord::Migration
  def change
    create_table :programmes do |t|
      t.integer :VisId
      t.integer :screens
      t.integer :priority

      t.timestamps
    end
  end
end
