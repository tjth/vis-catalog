class AddIsDefaultToVisualisations < ActiveRecord::Migration
  def change
    add_column :visualisations, :isDefault, :boolean
  end
end
