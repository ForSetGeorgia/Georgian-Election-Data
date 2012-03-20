class CreateShapes < ActiveRecord::Migration
  def self.up
    create_table :shapes do |t|
      t.integer :parent_id
      t.integer :shape_type_id
      t.string :common_id
      t.column :geo_data, 'longtext'

      t.timestamps
    end
    Shape.create_translation_table! :name => :string    
  end
  def self.down
    drop_table :shapes
    Shape.drop_translation_table!    
  end
end
