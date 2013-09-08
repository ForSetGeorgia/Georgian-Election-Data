class LoadIndProfiles < ActiveRecord::Migration
  require 'json_cache'
  def up
    require 'csv'    

    CoreIndicatorTranslation.transaction do
      data = File.read("#{Rails.root}/db/csv/indicator_profiles.csv")
      csv = CSV.parse(data, :headers => false)

      # format of row is: language (georgian|english), indicator name, summary text
      csv.each_with_index do |row, i|
        if row[0].present? && row[1].present? && row[2].present?
          # find record for this indicator
          indicator = CoreIndicatorTranslation
                      .where(:locale => row[0] == "Georgian" ? 'ka' : 'en', :name => row[1].strip)
                      .readonly(false)
          if indicator.present?
            indicator.first.summary = row[2]
            indicator.first.save      
          else
            puts "********* Row #{i+1} - could not find indicator: #{row[1]}"
          end
        else
            puts "********* Row #{i+1} - missing data and could not save"
        end
      end
    end
    JsonCache.clear_all
  end

  def down
    CoreIndicatorTranslation.update_all(:summary => nil)
    JsonCache.clear_all
  end
end
