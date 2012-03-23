class ChangeShapeName < ActiveRecord::Migration
  def up
    rename_column :shapes, :geo_data, :geometry
  end

  def down
    rename_column :shapes, :geometry, :geo_data
  end
end
