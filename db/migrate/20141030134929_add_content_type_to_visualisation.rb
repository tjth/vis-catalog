class AddContentTypeToVisualisation < ActiveRecord::Migration
  def change
    add_column :users, :content_type, :integer
  end
end
