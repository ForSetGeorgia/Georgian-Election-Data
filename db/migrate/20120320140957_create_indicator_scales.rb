class CreateIndicatorScales < ActiveRecord::Migration
  def self.up
    create_table :indicator_scales do |t|
      t.integer :indicator_id
      t.integer :min
      t.integer :max

      t.timestamps
    end
  end
  def self.down
    drop_table :indicator_scales
  end
end
