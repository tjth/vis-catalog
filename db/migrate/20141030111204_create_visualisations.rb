class CreateVisualisations < ActiveRecord::Migration
  def change
    create_table :visualisations do |t|

      t.timestamps
    end
  end
end
