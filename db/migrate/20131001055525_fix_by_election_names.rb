class FixByElectionNames < ActiveRecord::Migration
  def up
    EventTranslation.transaction do
      events = EventTranslation.where("name like '%bi-election%'").readonly(false)
      if events.present?
        puts "found #{events.length} events"
        events.each do |event|
          event.name = event.name.gsub('Bi-election', 'By-election')        
          event.name_abbrv = event.name_abbrv.gsub('Bi-election', 'By-election')        
          puts "- new name is #{event.name}"
          event.save
        end
      end

      I18n.available_locales.each do |locale|
        Rails.cache.clear("event_menu_json_#{locale}")
      end
    end
  end

  def down
    EventTranslation.transaction do
      events = EventTranslation.where("name like '%by-election%'").readonly(false)
      if events.present?
        events.each do |event|
          event.name = event.name.gsub('By-election', 'Bi-election')        
          event.name_abbrv = event.name_abbrv.gsub('By-election', 'Bi-election')        
          event.save
        end
      end

      I18n.available_locales.each do |locale|
        Rails.cache.clear("event_menu_json_#{locale}")
      end
    end
  end
end
