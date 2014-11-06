class AddFileToVisualisations < ActiveRecord::Migration
  def change
    add_column :visualisations, :file, :string
  end
end
