class AddProgrammesRefToTimeslots < ActiveRecord::Migration
  def change
    add_reference :timeslots, :programmes, index: true
  end
end
