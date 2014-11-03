class AddUserIdToVisualisation < ActiveRecord::Migration
  def change
    add_column :visualisations, :user_id, :integer
  end
end
