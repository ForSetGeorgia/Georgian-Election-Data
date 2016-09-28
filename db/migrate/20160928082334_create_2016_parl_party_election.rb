class Create2016ParlPartyElection < ActiveRecord::Migration
# the ids are the election party id, not related to any id in the system
# parties = [
    # {id: 1, name: 'State for the People', status: 'new'}
    # {id: 2, name: 'Progressive Democratic Movement', status: 'new'}
    # {id: 3, name: 'Democratic Movement', status: 'new'}
    # {id: 4, name: 'Georgian Group', status: 'existing'}
    # {id: 5, name: 'United National Movement', status: 'existing'}
    # {id: 6, name: 'Republican Party', status: 'existing'}
    # {id: 7, name: 'For United Georgia', status: 'new'}
    # {id: 8, name: 'Alliance of Patriots', status: 'existing'}
    # {id: 10, name: 'Labour', status: 'existing'}
    # {id: 11, name: 'People\'s Government', status: 'new'}
    # {id: 12, name: 'Communist Party - Stalin', status: 'new'}
    # {id: 14, name: 'Georgia for Peace', status: 'new'}
    # {id: 15, name: 'Socialist Workers Party', status: 'new'}
    # {id: 16, name: 'United Communist Party', status: 'existing'}
    # {id: 17, name: 'Georgia', status: 'new'}
    # {id: 18, name: 'Georgian Idea', status: 'new'}
    # {id: 19, name: 'Industrialists - Our Homeland', status: 'new'}
    # {id: 22, name: 'Merab Kostava Society', status: 'existing'}
    # {id: 23, name: 'Ours - People\'s Party', status: 'new'}
    # {id: 25, name: 'Leftist Alliance', status: 'new'}
    # {id: 26, name: 'National Forum', status: 'new'}
    # {id: 27, name: 'Free Democrats', status: 'new'}
    # {id: 28, name: 'In the Name of the Lord', status: 'existing'}
    # {id: 30, name: 'Our Georgia', status: 'existing'}
    # {id: 41, name: 'Georgian Dream', status: 'existing'}
#   ]

# ids are core ids - names are just there to indicate what the party is
EXISTING_PARTIES = [
  [26, "Georgian Group"],
  [59, "United National Movement"],
  [50, "Republican Party"],
  [134, "Alliance of Patriots"],
  [36, "Labour"],
  [58, "United Communist Party"],
  [72, "Merab Kostava Society"],
  [133, "In the Name of the Lord"],
  [137, "Our Georgia"],
  [74, "Georgian Dream"]
]

NEW_PARTIES = {
  :en => [
    ['State for the People', 'State for People', 'Vote share State for the People (%)', ''],
    ['Progressive Democratic Movement', 'Progressive Dem Mvmnt', 'Vote share Progressive Democratic Movement (%)', ''],
    ['Democratic Movement', 'Dem Mvmnt', 'Vote share Democratic Movement (%)', ''],
    ['For United Georgia', 'United Georgia', 'Vote share For United Georgia (%)', ''],
    ['People\'s Government', 'People\'s Govt', 'Vote share People\'s Government (%)', ''],
    ['Communist Party - Stalin', 'Communist - Stalin', 'Vote share Communist Party - Stalin (%)', ''],
    ['Georgia for Peace', 'Geo for Peace', 'Vote share Georgia for Peace (%)', ''],
    ['Socialist Workers Party', 'Socialist Workers', 'Vote share Socialist Workers Party (%)', ''],
    ['Georgia', 'Georgia', 'Vote share Georgia (%)', ''],
    ['Georgian Idea', 'Georgian Idea', 'Vote share Georgian Idea (%)', ''],
    ['Industrialists - Our Homeland', 'Indust - Homeland', 'Vote share Industrialists - Our Homeland (%)', ''],
    ['Ours - People\'s Party', 'Ours - Ppl Party', 'Vote share Ours - People\'s Party (%)', ''],
    ['Leftist Alliance', 'Left Alliance', 'Vote share Leftist Alliance (%)', ''],
    ['National Forum', 'National Forum', 'Vote share National Forum (%)', ''],
    ['Free Democrats', 'Free Dems', 'Vote share Free Democrats (%)', '']
  ],
  :ka => [
    ['სახელმწიფო ხალხისთვის', 'სახელმწ. ხალხისთვის', 'ხმების გადანაწილება, სახელმწიფო ხალხისთვის (%)'],
    ['პროგრესულ -დემოკრატიული მოძრაობა', 'პროგრესულ-დემოკრატიული მოძრ.', 'ხმების გადანაწილება, პროგრესულ -დემოკრატიული მოძრაობა (%)'],
    ['დემოკრატიული მოძრაობა', 'დემოკრატიული მოძრ.', 'ხმების გადანაწილება, დემოკრატიული მოძრაობა (%)'],
    ['თამაზ მეჭიაური ერთიანი საქართველოსთვის', 'მეჭიაური ერთ. საქ-ოსთვის', 'ხმების გადანაწილება, თამაზ მეჭიაური ერთიანი საქართველოსთვის (%)'],
    ['სახალხო ხელისუფლება', 'სახალხო ხელისუფლება', 'ხმების გადანაწილება, სახალხო ხელისუფლება (%)'],
    ['კომუნისტური პარტია - სტალინელები', 'კომ. პარტია - სტალინელები', 'ხმების გადანაწილება, კომუნისტური პარტია - სტალინელები (%)'],
    ['საქართველოს მშვიდობისათვის', 'საქ-ოს მშვიდობისათვის', 'ხმების გადანაწილება, საქართველოს მშვიდობისათვის (%)'],
    ['მშრომელთა სოციალისტური პარტია', 'მშრომელთა სოც. პარტია', 'ხმების გადანაწილება, მშრომელთა სოციალისტური პარტია (%)'],
    ['საქართველო', 'საქართველო', 'ხმების გადანაწილება, საქართველო (%)'],
    ['ქართული იდეა', 'ქართული იდეა', 'ხმების გადანაწილება, ქართული იდეა (%)'],
    ['მრეწველები, ჩვენი სამშობლო', 'მრეწველები, ჩვენი სამშობლო', 'ხმების გადანაწილება, მრეწველები, ჩვენი სამშობლო (%)'],
    ['ჩვენები - სახალხო პარტია', 'ჩვენები - სახალხო პარტია', 'ხმების გადანაწილება, ჩვენები - სახალხო პარტია (%)'],
    ['მემარცხენე ალიანსი', 'მემარცხენე ალიანსი', 'ხმების გადანაწილება, მემარცხენე ალიანსი (%)'],
    ['ეროვნული ფორუმი', 'ეროვნული ფორუმი', 'ხმების გადანაწილება, ეროვნული ფორუმი (%)'],
    ['უფლის სახელით', 'უფლის სახელით', 'ხმების გადანაწილება, უფლის სახელით (%)']
  ]
}

  def up
    clone_event_id = 31 # 2012 parl party list
    clone_ind_event_id = 31 # 2012 parl party list
    clone_core_ind_id = 59 #unm

    Event.transaction do
      event = Event.clone_from_event(clone_event_id, '2016-10-08')

      if event.present?
        puts "event created with id of #{event.id}"

        # update values
        event.shape_id = 69898
        event.event_translations.each do |trans|
          trans.name = trans.name.gsub('2012', '2016')
          trans.name_abbrv = trans.name_abbrv.gsub('2012', '2016')
          trans.description = trans.description.gsub('October 1, 2012', 'October 8, 2016').gsub('2012 წლის 1 ოქტომბერის', '2016 წლის 8 ოქტომბერის')
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
          puts "- creating party #{NEW_PARTIES[:en][index][0]}"
          party = CoreIndicator.new(:indicator_type_id => 2, :number_format => '%', :color => NEW_PARTIES[:en][index][3])
          party.core_indicator_translations.build(:locale => 'en', :name => NEW_PARTIES[:en][index][0],
            :name_abbrv => NEW_PARTIES[:en][index][1], :description => NEW_PARTIES[:en][index][2])
          party.core_indicator_translations.build(:locale => 'ka', :name => NEW_PARTIES[:ka][index][0],
            :name_abbrv => NEW_PARTIES[:ka][index][1], :description => NEW_PARTIES[:ka][index][2])
          party.save


          # now clone the indicators and scales for this new indciator
          puts "-- creating indicators"
          Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

        end

        # create a live menu for this event
        start_date = '2016-09-28'
        end_date = '2016-10-31'
        data_at = '2016-10-09 03:00:00 +0400'
        if Time.now.to_date.to_s <= end_date
          puts "-> creating live event menu item"
          MenuLiveEvent.create(event_id: event.id, menu_start_date: start_date, menu_end_date: end_date, data_available_at: data_at)
        end

        I18n.available_locales.each do |locale|
          JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
        end


      end
    end
  end

  def down
    Event.transaction do
      event = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Party List'}).first
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
