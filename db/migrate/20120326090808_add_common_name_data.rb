class AddCommonNameData < ActiveRecord::Migration
  def up
		add_column :data, :common_name, :string
  end

  def down
		remove_column :data, :common_name, :string
  end
end
