class TurnOffLiveEvents < ActiveRecord::Migration
  def up
    #for each offical dataset, if that event also has live, turn off live
    DataSet.transaction do
    
      official_sets = DataSet.where(:data_type => Datum::DATA_TYPE[:official], :show_to_public => true)
      if official_sets.present?
        official_sets.map{|x| x.event_id}.uniq.each do |event_id|
          live_sets = DataSet.where(:event_id => event_id, :data_type => Datum::DATA_TYPE[:live], :show_to_public => true)
          if live_sets.present?
            puts "event id #{event_id} has live data, turning off"
            live_sets.each do |set|
              set.show_to_public = false
              set.save
            end

            # turn off event has_live_data flag
            event = Event.find(event_id)
		        event.has_live_data = false
            event.save

            # clear the menu cache
            I18n.available_locales.each do |locale|
              Rails.cache.delete("live_event_menu_json_#{locale}")
              Rails.cache.delete("event_menu_json_#{locale}")
              Rails.cache.delete("events_by_type_#{event.event_type_id}_#{locale}")
            end
          end
        end
      end
    end
  end

  def down
    # do nothing
  end
end
