class Create2017VotersList < ActiveRecord::Migration
  def up
    clone_event_id = 36 # 2013 voters list
    clone_ind_event_id = 36 # 2013 voters list

    Event.transaction do
      event = Event.clone_from_event(clone_event_id, '2017-10-21')

      if event.present?
        puts "event created with id of #{event.id}"

        # update values
        event.shape_id = 65134
        event.default_core_indicator_id = 17
        event.event_translations.each do |trans|
          if trans.locale == 'ka'
            trans.name = '2017 წლის ოქტომბერის ამომრჩეველთა სია'
            trans.name_abbrv = '2017 ოქტომბერის'
          elsif trans.locale == 'en'
            trans.name = '2017 October Voters List'
            trans.name_abbrv = '2017 October'
          end
        end
        event.save

        # clone event components
        # core indicators type: 1 = other; 2 = results (party)
        puts "- getting 'other' core ids to clone"
        # - get 'other' indciators from clone
        inds = Indicator.select('distinct core_indicator_id').joins(:core_indicator)
                .where(:indicators => {:event_id => clone_ind_event_id, :ancestry => nil}, :core_indicators => {:indicator_type_id => 1}).pluck(:core_indicator_id).sort

        if inds.present?
          puts '> cloning event components'
          event.clone_event_components(clone_ind_event_id, core_indicator_ids: inds)
        end


        ################################################
        # load the data
        ################################################
        puts "-> loading data"
        locale = I18n.locale
        I18n.locale = :en
        file_path = "#{Rails.root}/db/load data/2017/upload_2017_oct_voters_list.csv"
        Datum.build_from_csv(event.id,
              Datum::DATA_TYPE[:official],
              nil,
              nil,
              '2017-10-20',
              File.new(file_path),
              true
        )
        I18n.locale = locale


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
      event = Event.includes(:event_translations).where(:event_date => '2017-10-21', event_translations: {name: '2017 October Voters List'}).first
      if event.present?
        puts "deleting the event"
        event.destroy

        puts "clearing cache"
        I18n.available_locales.each do |locale|
          JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
        end
      end
    end
  end
end
