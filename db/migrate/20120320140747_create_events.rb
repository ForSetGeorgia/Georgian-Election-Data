class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.int :shape_id

      t.timestamps
    end
    Event.create_translation_table! :name => :string    
  end
  def self.down
    drop_table :events
    Event.drop_translation_table!    
  end
end
