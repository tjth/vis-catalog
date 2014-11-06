class RemoveContentTypeFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :content_type
  end
end
