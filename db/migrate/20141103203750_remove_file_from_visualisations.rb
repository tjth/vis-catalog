class RemoveFileFromVisualisations < ActiveRecord::Migration
  def change
    remove_column :visualisations, :file
  end
end
