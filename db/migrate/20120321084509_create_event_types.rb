class CreateEventTypes < ActiveRecord::Migration
  def self.up
    create_table :event_types do |t|
      t.timestamps
    end
    EventType.create_translation_table! :name => :string
  end
  def self.down
    drop_table :event_types
    EventType.drop_translation_table!    
  end
end
