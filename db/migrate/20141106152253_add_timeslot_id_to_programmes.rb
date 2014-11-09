class AddTimeslotIdToProgrammes < ActiveRecord::Migration
  def change
	add_column :programmes, :timeslot_id, :integer
  end
end
