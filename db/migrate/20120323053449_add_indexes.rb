class AddIndexes < ActiveRecord::Migration
  def up
    add_index :data, :common_id
    add_index :data, :indicator_id
    add_index :events, :event_type_id
    add_index :events, :shape_id
    add_index :indicator_scales, :indicator_id
    add_index :indicators, :event_id
    add_index :indicators, :shape_type_id
    add_index :shapes, :common_id
    add_index :shapes, :shape_type_id
  end

  def down
    remove_index :data, :common_id
    remove_index :data, :indicator_id
    remove_index :events, :event_type_id
    remove_index :events, :shape_id
    remove_index :indicator_scales, :indicator_id
    remove_index :indicators, :event_id
    remove_index :indicators, :shape_type_id
    remove_index :shapes, :common_id
    remove_index :shapes, :shape_type_id
  end
end
