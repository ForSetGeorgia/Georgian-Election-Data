class AddAncestryToShapeTypes < ActiveRecord::Migration
  def change
    add_column :shape_types, :ancestry, :string
  end
end
