class AddFileToVisualisations < ActiveRecord::Migration
  def change
    add_column :visualisations, :filepath, :string
  end
end
