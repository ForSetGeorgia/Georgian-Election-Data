class AddRerunElection < ActiveRecord::Migration
# the ids are the election party id, not related to any id in the system
# parties = [
    # {id: 1, name: 'State for the People', status: 'existing'}
    # {id: 3, name: 'Democratic Movement', status: 'existing'}
    # {id: 5, name: 'United National Movement', status: 'existing'}
    # {id: 7, name: 'For United Georgia', status: 'existing'}
    # {id: 8, name: 'Alliance of Patriots', status: 'existing'}
    # {id: 17, name: 'Georgia', status: 'existing'}
    # {id: 23, name: 'Ours - People\'s Party', status: 'existing'}
    # {id: 28, name: 'In the Name of the Lord', status: 'existing'}
    # {id: 41, name: 'Georgian Dream', status: 'existing'}
#   ]

# ids are core ids - names are just there to indicate what the party is
EXISTING_PARTIES = [
  [144, 'State for the People'],
  [146, 'Democratic Movement'],
  [59, "United National Movement"],
  [147, 'For United Georgia'],
  [134, "Alliance of Patriots"],
  [152, 'Georgia'],
  [155, 'Ours - People\'s Party'],
  [133, "In the Name of the Lord"],
  [74, "Georgian Dream"]
]


  def up
    clone_event_id = 46 # 2016 parl major
    clone_ind_event_id = 46 # 2016 parl major
    clone_core_ind_id = 59 #unm

    Event.transaction do
      event = Event.clone_from_event(clone_event_id, '2016-10-22')

      if event.present?
        puts "event created with id of #{event.id}"

        # update values
        event.event_translations.each do |trans|
          if trans.locale == 'ka'
            trans.name = '2016 წლის საპარლამენტო არჩევნები - მაჟორიტარული მეორე ტური'
            trans.name_abbrv = '2016 წლის საპარლამენტო არჩევნები - მაჟორიტარული მეორე ტური'
            trans.description = '2016 წლის 22 ოქტომბერის საპარლამენტო არჩევნების მეორე ტურის მაჟორიტარული ოლქის 4 უბნის შედეგები. პარლამენტის წევრები აირჩევიან ოთხი წლის ვადით.'
          elsif trans.locale == 'en'
            trans.name = '2016 Parliamentary - Majoritarian Rerun'
            trans.name_abbrv = '2016 Parliamentary - Majoritarian Rerun'
            trans.description = 'The results of the October 22, 2016 rerun election for 4 precincts in two majoritarian districts of Parliament. Members of Parliament are elected for four year terms.'
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
        start_date = '2016-10-21'
        end_date = '2016-11-21'
        data_at = '2016-10-23 10:00:00 +0400'
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
      event = Event.includes(:event_translations).where(:event_date => '2016-10-22', event_translations: {name: '2016 Parliamentary - Majoritarian Rerun'}).first
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
