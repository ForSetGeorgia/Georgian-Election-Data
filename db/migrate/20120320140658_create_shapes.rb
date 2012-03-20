class CreateShapes < ActiveRecord::Migration
  def self.up
    create_table :shapes do |t|
      t.int :parent_id
      t.int :shape_type_id
      t.string :common_id
      t.longtext :geo_data

      t.timestamps
    end
    Shape.create_translation_table! :name => :string    
  end
  def self.down
    drop_table :shapes
    Shape.drop_translation_table!    
  end
end
