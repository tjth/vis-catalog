class FixProgrammeColumnName < ActiveRecord::Migration
  def change
    rename_column :programmes, :VisId, :vis_ID
  end
end
