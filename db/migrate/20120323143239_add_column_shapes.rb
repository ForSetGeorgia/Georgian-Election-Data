class AddColumnShapes < ActiveRecord::Migration
  def up
		add_column :shapes, :common_name, :string
  end

  def down
		remove_column :shapes, :common_name, :string
  end
end
