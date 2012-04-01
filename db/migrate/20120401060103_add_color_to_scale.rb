class AddColorToScale < ActiveRecord::Migration
  def change
		add_column :indicator_scales, :color, :string
  end
end
