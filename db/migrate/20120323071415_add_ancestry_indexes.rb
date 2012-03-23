class AddAncestryIndexes < ActiveRecord::Migration
  def up
    add_index :shapes, :ancestry
    add_index :shape_types, :ancestry    
  end

  def down
    remove_index :shapes, :ancestry
    remove_index :shape_types, :ancestry
  end
end
