class AddProgrammesRefToTimeslots < ActiveRecord::Migration
  def change
    add_reference :programmes, :timeslot, index: true
  end
end
