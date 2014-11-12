class AddDateToTimeslots < ActiveRecord::Migration
  def change
    add_column :timeslots, :date, :date
  end
end
