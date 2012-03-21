class ChangeIndicatorScales < ActiveRecord::Migration
  def up
    remove_column :indicator_scales, :max
    remove_column :indicator_scales, :min

    IndicatorScale.create_translation_table! :name => :string
  end

  def down
    add_column :indicator_scales, :max, :integer
    add_column :indicator_scales, :min, :integer
    IndicatorScale.drop_translation_table!    
  end
end
