class AddUsernameToTestusers < ActiveRecord::Migration
  def change
    add_column :testusers, :username, :string
  end
end
