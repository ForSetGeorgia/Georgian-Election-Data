class RemoveAmendmentIndicators < ActiveRecord::Migration
  def up
    # the core indicators to delete have ids > 160
    # - delete the indicators and all of its data
    core_ind_id = 160


    puts "deleting event indicators and data"
    indicators = Indicator.where('core_indicator_id > ?', core_ind_id)
    indicator_ids = indicators.map{|x| x.id}.uniq
    event_ids = indicators.map{|x| x.event_id}.uniq
    Datum.where(indicator_id: indicator_ids).delete_all
    IndicatorScale.where(indicator_id: indicator_ids).destroy_all
    Indicator.where(id: indicator_ids).delete_all

    puts "deleting event indicator relationships"
    EventIndicatorRelationship.where(:event_id => event_ids).where('core_indicator_id > ?', core_ind_id).destroy_all

    puts "clearing cache"
    I18n.available_locales.each do |locale|
      JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
      JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
    end
    
    # delete event data
    event_ids.each do |event_id|
      JsonCache.clear_data_files(event_id)
    end

  end

  def down
    puts 'do nothing'

    puts "clearing cache"
    I18n.available_locales.each do |locale|
      JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
      JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
    end

    # delete event data
    event_ids.each do |event_id|
      JsonCache.clear_data_files(event_id)
    end

  end
end
