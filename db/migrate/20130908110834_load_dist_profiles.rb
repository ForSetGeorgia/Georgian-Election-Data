class LoadDistProfiles < ActiveRecord::Migration
  require 'json_cache'
  def up
    require 'csv'    

    UniqueShapeNameTranslation.transaction do
      data = File.read("#{Rails.root}/db/csv/district_profiles.csv")
      csv = CSV.parse(data, :headers => false)

      # format of row is: language (georgian|english), district name, summary text
      csv.each_with_index do |row, i|
        if row[0].present? && row[1].present? && row[2].present?
          # find record for this district
          district = UniqueShapeNameTranslation.joins(:unique_shape_name)
                      .where(:unique_shape_names => {:shape_type_id => [3,7]}, 
                              :unique_shape_name_translations => {:locale => row[0] == "Georgian" ? 'ka' : 'en', :common_name => row[1].strip})
                      .readonly(false)
          if district.present?
            district.first.summary = row[2]
            district.first.save      
          else
            puts "********* Row #{i+1} - could not find district: #{row[1]}"
          end
        else
            puts "********* Row #{i+1} - missing data and could not save"
        end
      end
    end
    JsonCache.clear_all
  end

  def down
    UniqueShapeNameTranslation.update_all(:summary => nil)
    JsonCache.clear_all
  end
end
