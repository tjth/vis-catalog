class AddVisualisationsRefToProgrammes < ActiveRecord::Migration
  def change
    add_reference :programmes, :visualisations, index: true
  end
end
