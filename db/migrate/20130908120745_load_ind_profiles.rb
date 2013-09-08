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
          # - indicator name is in english for both languages 
          #   so if Georgian, use english to find record and then get geo recrod
          indicator = CoreIndicatorTranslation
                      .where(:locale => 'en', :name => row[1].strip)
                      .readonly(false)

          if indicator.present? && row[0] == "Georgian"
            indicator = CoreIndicatorTranslation
                      .where(:locale => 'ka', :core_indicator_id => indicator.first.core_indicator_id)
                      .readonly(false)
          end

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
