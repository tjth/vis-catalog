class CreatePlayoutSessions < ActiveRecord::Migration
  def change
    create_table :playout_sessions do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :start_screen
      t.integer :end_screen

      t.timestamps
    end
  end
end
