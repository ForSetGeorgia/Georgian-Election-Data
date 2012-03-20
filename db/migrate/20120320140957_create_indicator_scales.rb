class CreateIndicatorScales < ActiveRecord::Migration
  def self.up
    create_table :indicator_scales do |t|
      t.int :indicator_id
      t.string :name
      t.int :min
      t.int :max

      t.timestamps
    end
  end
  def self.down
    drop_table :indicator_scales
  end
end
