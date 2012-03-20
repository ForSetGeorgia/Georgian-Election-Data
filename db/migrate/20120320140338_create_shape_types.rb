class CreateShapeTypes < ActiveRecord::Migration
  def self.up
    create_table :shape_types do |t|
      t.timestamps
    end
    ShapeType.create_translation_table! :name => :string    
  end
  def self.down
    drop_table :shape_types
    ShapeType.drop_translation_table!    
  end
end
