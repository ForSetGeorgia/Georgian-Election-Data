class Reload2017Indicators < ActiveRecord::Migration
  def up
    start = Time.now
    locale = I18n.locale
    I18n.locale = :en
    folder_path = "#{Rails.root}/db/load data/2017/"

    Indicator.transaction do
      puts "delete all indciators first"
      event_ids = Event.where('year(event_date) = 2017').where(event_type_id: 5).pluck(:id)
      Indicator.destroy_all_indicators(Indicator.where(event_id: event_ids).pluck(:id))

      puts 'fixing party list'
      Indicator.build_from_csv(File.open(folder_path + 'fix_indicator_2017_party_list.csv'))

      puts 'fixing major'
      Indicator.build_from_csv(File.open(folder_path + 'fix_indicator_2017_majoritarian.csv'))

      puts 'fixing mayor'
      Indicator.build_from_csv(File.open(folder_path + 'fix_indicator_2017_mayor.csv'))

    end

    I18n.locale = locale

    puts "total time = #{Time.now - start} seconds"
  end

  def down
    puts 'do nothing'
  end
end
