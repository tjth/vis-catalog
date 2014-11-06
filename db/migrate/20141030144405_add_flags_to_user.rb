class AddFlagsToUser < ActiveRecord::Migration
  def change
    add_column :users, :isAdmin, :boolean
    add_column :users, :isApproved, :boolean
  end
end
