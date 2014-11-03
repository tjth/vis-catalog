class AddContentToVisualisations < ActiveRecord::Migration
  def change
    add_column :visualisations, :content, :string
  end
end
