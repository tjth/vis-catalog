class AddProgrammesRefToVisualisation < ActiveRecord::Migration
  def change
    add_reference :programmes, :visualisation, index: true
  end
end
