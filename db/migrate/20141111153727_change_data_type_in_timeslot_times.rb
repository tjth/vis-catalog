class ChangeDataTypeInTimeslotTimes < ActiveRecord::Migration
  def change
    change_column :timeslots, :start_time, :datetime
    change_column :timeslots, :end_time, :datetime
  end
end
