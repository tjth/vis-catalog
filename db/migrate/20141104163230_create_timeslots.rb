class CreateTimeslots < ActiveRecord::Migration
  def change
    create_table :timeslots do |t|
      t.integer :weekday
      t.time :startTime
      t.time :endTime

      t.timestamps
    end
  end
end
