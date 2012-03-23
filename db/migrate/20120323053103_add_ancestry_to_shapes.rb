class AddAncestryToShapes < ActiveRecord::Migration
  def change
    remove_column :shapes, :parent_id
    add_column :shapes, :ancestry, :string
  end
end
