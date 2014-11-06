class AddContentTypeToVisualisations < ActiveRecord::Migration
  def change
    add_column :visualisations, :content_type, :integer
  end
end
