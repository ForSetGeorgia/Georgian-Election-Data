class AddRunoff < ActiveRecord::Migration
# the ids are the election party id, not related to any id in the system
# parties = [
    # {id: 5, name: 'United National Movement', status: 'existing'}
    # {id: 19, name: 'Industrialists - Our Homeland', status: 'new'}
    # {id: 27, name: 'Free Democrats', status: 'new'}
    # {id: 41, name: 'Georgian Dream', status: 'existing'}
#   ]

# ids are core ids - names are just there to indicate what the party is
EXISTING_PARTIES = [
  [59, "United National Movement"],
  [154, 'Industrialists - Our Homeland'],
  [158, 'Free Democrats'],
  [74, "Georgian Dream"],
  [87, 'Initiative Group']
]


  def up
    clone_event_id = 46 # 2016 parl major
    clone_ind_event_id = 46 # 2016 parl major
    clone_core_ind_id = 59 #unm

    Event.transaction do
      event = Event.clone_from_event(clone_event_id, '2016-10-30')

      if event.present?
        puts "event created with id of #{event.id}"

        # update values
        event.event_translations.each do |trans|
          if trans.locale == 'ka'
            trans.name = '2016 წლის საპარლამენტო არჩევნები - მაჟორიტარული არჩევნების მეორე ტური'
            trans.name_abbrv = '2016 მაჟორიტარული არჩევნების მეორე ტური'
            trans.description = '2016 წლის 30 ოქტომბერს 50 მაჟორიტარულ ოლქში ჩატარებული საპარლამენტო არჩევნების მეორე ტურის შედეგები. პარლამენტის წევრები აირჩევიან 4 წლის ვადით.'
          elsif trans.locale == 'en'
            trans.name = '2016 Parliamentary - Majoritarian Runoff'
            trans.name_abbrv = '2016 Majoritarian Runoff'
            trans.description = 'The results of the October 30, 2016 ruoff election for 50 majoritarian districts of Parliament. Members of Parliament are elected for four year terms.'
          end
        end
        event.save

        # clone event components
        # core indicators type: 1 = other; 2 = results (party)
        puts "- getting 'other' core ids to clone"
        # - get 'other' indciators from clone
        inds = Indicator.select('distinct core_indicator_id').joins(:core_indicator)
                .where(:indicators => {:event_id => clone_ind_event_id, :ancestry => nil}, :core_indicators => {:indicator_type_id => 1}).pluck(:core_indicator_id).sort

        # copy over pre-existing parties
        puts "- getting existing party core ids to clone"
        inds << EXISTING_PARTIES.map{|x| x[0]}
        inds.flatten!

        if inds.present?
          puts '> cloning event components'
          event.clone_event_components(clone_ind_event_id, core_indicator_ids: inds, clone_indicators: true)
        end

        puts "-----------------"

        # create a live menu for this event
        start_date = '2016-10-25'
        end_date = '2016-11-25'
        data_at = '2016-10-31 10:00:00 +0400'
        if Time.now.to_date.to_s <= end_date
          puts "-> creating live event menu item"
          MenuLiveEvent.create(event_id: event.id, menu_start_date: start_date, menu_end_date: end_date, data_available_at: data_at)
        end

        I18n.available_locales.each do |locale|
          Rails.cache.delete("live_event_menu_json_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
        end


      end
    end
  end

  def down
    Event.transaction do
      event = Event.includes(:event_translations).where(:event_date => '2016-10-30', event_translations: {name: '2016 Parliamentary - Majoritarian Runoff'}).first
      if event.present?
        puts "deleting live menu"
        MenuLiveEvent.where(event_id: event.id).delete_all

        puts "deleting the event"
        event.destroy


        puts "clearing cache"
        I18n.available_locales.each do |locale|
          Rails.cache.delete("live_event_menu_json_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
        end
      end
    end
  end
end
