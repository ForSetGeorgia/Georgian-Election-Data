class CreateData < ActiveRecord::Migration
  def self.up
    create_table :data do |t|
      t.int :indicator_id
      t.string :common_id
      t.text :value

      t.timestamps
    end
  end
  def self.down
    drop_table :data
  end
end
