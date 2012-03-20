class CreateIndicators < ActiveRecord::Migration
  def self.up
    create_table :indicators do |t|
      t.int :event_id
      t.int :shape_type_id

      t.timestamps
    end
    Indicator.create_translation_table! :name => :string    
  end
  def self.down
    drop_table :indicators
    Indicator.drop_translation_table!    
  end
end
