class AddPlayoutSessionsRefToVisualisation < ActiveRecord::Migration
  def change
    add_reference :playout_sessions, :visualisation, index: true
  end
end
