class FixTimeslotColumnNames < ActiveRecord::Migration
  def change
    rename_column :timeslots, :startTime, :start_time
    rename_column :timeslots, :endTime, :end_time
  end
end
