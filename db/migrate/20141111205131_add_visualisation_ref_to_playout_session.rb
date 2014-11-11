class AddVisualisationRefToPlayoutSession < ActiveRecord::Migration
  def change
    add_reference :playout_sessions, :visualisations, index: true
  end
end
