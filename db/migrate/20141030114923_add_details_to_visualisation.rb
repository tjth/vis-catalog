class AddDetailsToVisualisation < ActiveRecord::Migration
  def change
    add_column :visualisations, :link, :string
    add_column :visualisations, :name, :string
    add_column :visualisations, :description, :string
    add_column :visualisations, :notes, :string
    add_column :visualisations, :author_info, :string
  end
end
