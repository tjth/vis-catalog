class RemoveEmailFromTestusers < ActiveRecord::Migration
  def change
  	remove_column :testusers, :email
  end
end
