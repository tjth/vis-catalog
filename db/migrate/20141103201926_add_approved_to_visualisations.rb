class AddApprovedToVisualisations < ActiveRecord::Migration
  def change
    add_column :visualisations, :approved, :boolean
  end
end
