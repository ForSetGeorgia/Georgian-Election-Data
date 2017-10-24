class LoadPartyColors < ActiveRecord::Migration
  def up
    colors = [
      ['European Georgia', '#e57d8c'],
      ['Democratic Movement - Free Georgia', '#6187BE'],
      ['United Democratic Movement', '#e3e6de'],
      ['Georgian Unity and Development Party', '#8bb6be'],
      ['Georgia', '#d7df8f'],
      ['New Christian Democrats', '#e3ccab'],
      ['Unity - New Georgia', '#fe8e4d'],
      ['Lord Our Righteousness', '#9391d2']
    ]

    CoreIndicator.transaction do
      colors.each do |color|
        puts "#{color[0]}"
        ind_id = CoreIndicatorTranslation.where(name: color[0]).pluck(:core_indicator_id).first
        ind = CoreIndicator.find_by_id(ind_id) if ind_id.present?

        if ind.present?
          ind.color = color[1]
          ind.save
          puts "- saved color"
        end
      end
    end

    I18n.available_locales.each do |locale|
      JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
      JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
    end

  end

  def down
    puts 'do nothing'
  end
end
