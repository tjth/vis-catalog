class RemoveWeekdayFromTimeslots < ActiveRecord::Migration
  def change
    remove_column :timeslots, :weekday, :integer
  end
end
