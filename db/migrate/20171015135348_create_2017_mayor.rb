class Create2017Mayor < ActiveRecord::Migration
# the ids are the election party id, not related to any id in the system
# parties = [
##  # { "id": 1, "name": "State for the People", "status": "existing" },
  # { "id": 2, "name": "European Georgia", "status": "new" },
  # { "id": 3, "name": "Democratic Movement - Free Georgia", "status": "new" },
##  # { "id": 4, "name": "United Democratic Movement", "status": "new" },
  # { "id": 5, "name": "United National Movement", "status": "existing" },
  # { "id": 6, "name": "Republican Party of Georgia", "status": "existing" },
  # { "id": 7, "name": "For United Georgia", "status": "existing" },
  # { "id": 8, "name": "Alliance of Patriots", "status": "existing" },
  # { "id": 9, "name": "Leftist Alliance", "status": "existing" },
  # { "id": 10, "name": "Labour Party", "status": "existing" },
  # { "id": 11, "name": "National Democratic Party of Georgia", "status": "existing" },
  # { "id": 14, "name": "Georgian Unity and Development Party", "status": "new" },
##  # { "id": 15, "name": "Socialist Workers Party", "status": "existing" },
  # { "id": 17, "name": "Georgia", "status": "new" },
  # { "id": 18, "name": "Union of Georgian Traditionalists", "status": "existing" },
  # { "id": 20, "name": "National Forum", "status": "existing" },
##  # { "id": 22, "name": "Merab Kostava Society", "status": "existing" },
  # { "id": 23, "name": "New Christian Democrats", "status": "new" },
  # { "id": 27, "name": "Unity - New Georgia", "status": "new" },
  # { "id": 28, "name": "The Lord Our Righteousness", "status": "new" },
##  # { "id": 29, "name": "New Rights", "status": "existing" },
  # { "id": 31, "name": "Freedom Party", "status": "existing" },
##  # { "id": 34, "name": "Mamulishvili", "status": "existing" },
  # { "id": 37, "name": "United Communist Party", "status": "existing" },
  # { "id": 38, "name": "Party of People", "status": "existing" },
  # { "id": 39, "name": "Progressive Democratic Movement", "status": "existing" },
  # { "id": 41, "name": "Georgian Dream", "status": "existing" },
  # { "id": 42, "name": "Initiative Group", "status": "existing" }
  # { "id": 43, "name": "Initiative Group", "status": "existing" }
#   ]

# ids are core ids - names are just there to indicate what the party is
EXISTING_PARTIES = [
  # [144, "State for the People"],
  [59, "United National Movement"],
  [50, "Republican Party"],
  [147, "For United Georgia"],
  [134, "Alliance of Patriots"],
  [156, "Leftist Alliance"],
  [36, "Labour"],
  [43, "National Democratic Party"],
  # [151, "Socialist Workers Party"],
  [157, "National Forum"],
  # [72, "Merab Kostava Society"],
  # [64, "New Rights"],
  [24, "Freedom Party"],
  # [38, "Mamulishvili"],
  [58, "United Communist Party"],
  [143, "Party of People"],
  [145, "Progressive Democratic Movement"],
  [74, "Georgian Dream"]
]

EXISTING_PARTIES_NO_RELATIONSHIPS = [
  [122, "Union of Georgian Traditionalists"],
  [87, "Initiative Group"]

]

NEW_PARTIES = {
  :en => [
    ['European Georgia', 'Euro Georgia', 'Vote share European Georgia (%)', nil],
    ['Democratic Movement - Free Georgia', 'Dem Mvmnt', 'Vote share Democratic Movement - Free Georgia (%)', nil],
    # ['United Democratic Movement', 'United Dem Mvmnt', 'Vote share United Democratic Movement (%)', nil],
    ['Georgian Unity and Development Party', 'Geo Unity and Dvlpmnt', 'Vote share Georgian Unity and Development Party (%)', nil],
    ['Georgia', 'Georgia', 'Vote share Georgia (%)', nil],
    ['New Christian Democrats', 'New Christian Dems', 'Vote share New Christian Democrats (%)', nil],
    ['Unity - New Georgia', 'Unity-New Geo', 'Vote share Unity - New Georgia (%)', nil],
    ['Lord Our Righteousness', 'Lord Our Righteousness', 'Vote share The Lord Our Righteousness (%)', nil],

  ],
  :ka => [
    ['მოძრაობა თავისუფლებისთვის', 'ევროპული საქართველო', 'ხმების გადანაწილება, მოძრაობა თავისუფლებისთვის (%)'],
    ['დემოკრატიული მოძრაობა - თავისუფალი საქართველო', 'დემოკრატიული მოძრაობა', 'ხმების გადანაწილება, დემოკრატიული მოძრაობა - თავისუფალი საქართველო (%)'],
    # ['გაერთიანებული დემოკრატიული მოძრაობა', 'გაერთიანებული დემოკრატიული მოძრაობა', 'ხმების გადანაწილება, გაერთიანებული დემოკრატიული მოძრაობა (%)'],
    ['ერთობისა და განვითარების პარტია', 'ერთობა და განვითარება', 'ხმების გადანაწილება, ერთობისა და განვითარების პარტია (%)'],
    ['საქართველო', 'საქართველო', 'ხმების გადანაწილება, საქართველო (%)'],
    ['ახალი ქრისტიან დემოკრატები', 'ახალი ქრისტიან დემოკრატები', 'ხმების გადანაწილება, ახალი ქრისტიან დემოკრატები (%)'],
    ['ერთობა-ახალი საქართველო', 'ერთობა-ახალი საქართველო', 'ხმების გადანაწილება, ერთობა-ახალი საქართველო (%)'],
    ['უფალია ჩვენი სიმართლე', 'უფალია ჩვენი სიმართლე', 'ხმების გადანაწილება, უფალია ჩვენი სიმართლე (%)'],
  ]
}

  def up
    clone_event_id = 42 # 2014 mayor
    clone_ind_event_id = 42 # 2014 mayor
    clone_core_ind_id = 59 #unm

    Event.transaction do
      event = Event.clone_from_event(clone_event_id, '2017-10-21')

      if event.present?
        puts "event created with id of #{event.id}"

        # update values
        event.shape_id = 82062
        event.event_translations.each do |trans|
          trans.name = trans.name.gsub('2014', '2017')
          trans.name_abbrv = trans.name_abbrv.gsub('2014', '2017')
          trans.description = if trans.locale == 'en'
            'The results of the October 21, 2017 election. Mayors are elected for four year terms.'
          else
            '2017 წლის 21 ოქტომბერის მერის არჩევნების შედეგები. მერები არჩეულია ოთხი წლის ვადით.'
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
          event.clone_event_components(clone_ind_event_id, core_indicator_ids: inds)
        end

        puts "-----------------"

        # add new party indicators
        puts '- create new parties'

        (0..NEW_PARTIES[:en].length-1).each do |index|
          party = CoreIndicator.joins(:core_indicator_translations).where(core_indicator_translations: {name: NEW_PARTIES[:en][index][0]}).first
          if party.nil?
            puts "- creating party #{NEW_PARTIES[:en][index][0]}"
            party = CoreIndicator.new(:indicator_type_id => 2, :number_format => '%', :color => NEW_PARTIES[:en][index][3])
            party.core_indicator_translations.build(:locale => 'en', :name => NEW_PARTIES[:en][index][0],
              :name_abbrv => NEW_PARTIES[:en][index][1], :description => NEW_PARTIES[:en][index][2])
            party.core_indicator_translations.build(:locale => 'ka', :name => NEW_PARTIES[:ka][index][0],
              :name_abbrv => NEW_PARTIES[:ka][index][1], :description => NEW_PARTIES[:ka][index][2])
            party.save
          else
            puts "- found party #{NEW_PARTIES[:en][index][0]}"
          end


          # now clone the indicators and scales for this new indciator
          puts "-- creating indicators"
          Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

        end

        puts "-----------------"

        # add party indicators that have not had relationships in the past
        puts '- create indicators for existing party that has not been used'

        (0..EXISTING_PARTIES_NO_RELATIONSHIPS.length-1).each do |index|
          puts "- creating party #{EXISTING_PARTIES_NO_RELATIONSHIPS[index][1]}"
          party = CoreIndicator.find(EXISTING_PARTIES_NO_RELATIONSHIPS[index][0])

          # now clone the indicators and scales for this new indciator
          puts "-- creating indicators"
          Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)
        end



        # create a live menu for this event
        start_date = '2017-10-15'
        end_date = '2017-11-30'
        data_at = '2017-10-22 06:00:00 +0400'
        if Time.now.to_date.to_s <= end_date
          puts "-> creating live event menu item"
          MenuLiveEvent.create(event_id: event.id, menu_start_date: start_date, menu_end_date: end_date, data_available_at: data_at)
        end

        I18n.available_locales.each do |locale|
          JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
          JsonCache.clear_data_file("live_event_menu_json_#{locale}")
          JsonCache.clear_data_file("event_menu_json_#{locale}")
        end


      end
    end
  end

  def down
    Event.transaction do
      event = Event.includes(:event_translations).where(:event_date => '2017-10-21', event_translations: {name: '2017 Mayor Election'}).first
      if event.present?
        puts "deleting the event"
        event.destroy

        puts "clearing cache"
        I18n.available_locales.each do |locale|
          JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
          JsonCache.clear_data_file("live_event_menu_json_#{locale}")
          JsonCache.clear_data_file("event_menu_json_#{locale}")
        end
      end
    end
  end
end
