class Create2014GovernorRunoffElection < ActiveRecord::Migration
# the ids are the election party id, not related to any id in the system
# parties = [
###     {id: 1, name: 'Non-Parliamentary Opposition', status: 'new'},
###     {id: 2, name: 'Armed Veterans Patriots', status: 'new'},
#     {id: 3, name: 'United Opposition', status: 'exists'},
###     {id: 4, name: 'National Democratic Party of Georgia', status: 'exists'},
#     {id: 5, name: 'United National Movement', status: 'exists'},
#     {id: 6, name: 'Greens Party', status: 'new'},
###     {id: 7, name: 'In the Name of the Lord', status: 'new'},
#     {id: 8, name: 'Alliance of Patriots', status: 'new'},
###     {id: 9, name: 'Self-governance to People', status: 'new'},
###     {id: 10, name: 'People's Party, status: 'exists'},
###     {id: 11, name: 'Reformers', status: 'new'},
###     {id: 12, name: 'Our Georgia', status: 'new'},
###     {id: 13, name: 'Future Georgia', status: 'exists'},
#     {id: 14, name: 'Georgian Party', status: 'new'},
###     {id: 15, name: 'People's Movement', status: 'new'},
###     {id: 16, name: 'Christian Democrats', status: 'new'},
###     {id: 17, name: 'Unity Hall', status: 'new'},
#     {id: 18, name: 'Way of Georgia', status: 'new'},
###     {id: 19, name: 'Freedom', status: 'exists'},
###     {id: 20, name: 'Labour', status: 'exists'},
###     {id: 26, name: 'Party of People', status: 'new'},
###     {id: 30, name: 'Merab Kostava Society', status: 'exists'},
###     {id: 36, name: 'Labour Council', status: 'exists'},
#     {id: 41, name: 'Georgian Dream', status: 'exists'}
#   ]

# ids are core ids - names are just there to indicate what the party is
EXISTING_PARTIES = [
  [60, "United Opposition"],
#  [43, "National Democratic Party of Georgia"],
  [59, "United National Movement"],
  # [71, "People's Party"],
  # [25, "Future Georgia"],
 # [24, 'Freedom'],
  # [36, "Labour"],
  # [72, "Merab Kostava Society"],
  # [73, 'Labour Council'],
  [74, "Georgian Dream"]
]

NEW_PARTIES = {
  :en => [
    # ['Non-Parliamentary Opposition', 'Non-Parl Opp', 'Vote share Non-Parliamentary Opposition (%)', '#545f52'],
    # ['Armed Veterans Patriots', 'Armed Vets', 'Vote share Armed Veterans Patriots (%)', '#554d45'],
    ['Greens Party', 'Greens Party', 'Vote share Greens Party (%)', '#458a40'],
    # ['In the Name of the Lord', 'Name of Lord', 'Vote share In the Name of the Lord (%)', '#3a0c17'],
    ['Alliance of Patriots', 'Alliance', 'Vote share Alliance of Patriots (%)', '#C26254'],
    # ['Self-governance to People', 'Self-gov', 'Vote share Self-governance to People (%)', '#c6cc88'],
    # ['Reformers', 'Reformers', 'Vote share Reformers (%)', '#53501a'],
    # ['Our Georgia', 'Our Georgia', 'Vote share Our Georgia (%)', '#975710'],
    ['Georgian Party', 'Geo Party', 'Vote share Georgian Party (%)', '#8e9b8b'],
#    ['People\'s Movement', 'People\'s Mvmnt', 'Vote share People\'s Movement (%)', '#b8afba'],
    # ['Christian Democrats', 'Christian Dems', 'Vote share Christian Democratic Party (%)', '#ca9c6c'],
    # ['Unity Hall', 'Unity Hall', 'Vote share Unity Hall (%)', '#372a24'],
    ['Way of Georgia', 'Way of Georgia', 'Vote share Way of Georgia (%)', '#9b8b8e'],
    # ['Party of People', 'Party of People', 'Vote share Party of People (%)', '#231331']
  ],
  :ka => [
    # ['არასაპარლამენტო ოპოზიცია', 'არასაპარლამენტო ოპ.', 'ხმების გადანაწილება, არასაპარლამენტო ოპოზიცია (%)'],
    # ['საქართველოს ძალოვან ვეტერანთა და პატრიოტთა პოლიტიკური მოძრაობა', 'ვეტერანები', 'ხმების გადანაწილება, საქართველოს ძალოვან ვეტერანთა და პატრიოტთა პოლიტიკური მოძრაობა (%)'],
    ['მწვანეთა პარტია', 'მწვანეები', 'ხმების გადანაწილება, მწვანეთა პარტია (%)'],
    # ['უფლის სახელით', 'უფლის სახელით', 'ხმების გადანაწილება, უფლის სახელით (%)'],
    # ['საქართველოს პატრიოტთა ალიანსი', 'ალიანსი', 'ხმების გადანაწილება, საქართველოს პატრიოტთა ალიანსი (%)'],
    # ['თვითმმართველობა ხალხს', 'თვითმ. ხალხს', 'ხმების გადანაწილება, თვითმმართველობა ხალხს (%)'],
    ['რეფორმატორები', 'რეფორმატორები', 'ხმების გადანაწილება, რეფორმატორები (%)'],
    # ['ჩვენი საქართველო', 'ჩვენი საქართ.', 'ხმების გადანაწილება, ჩვენი საქართველო (%)'],
    ['ქართული პარტია', 'ქართ. პარტია', 'ხმების გადანაწილება, ქართული პარტია (%)'],
#    ['სახალხო მოძრაობა', 'სახალხო მოძ.', 'ხმების გადანაწილება, სახალხო მოძრაობა (%)'],
    # ['ქრისტიან დემოკრატები', 'ქრისტიან დემოკრატები', 'ხმების გადანაწილება, ქრისტიან დემოკრატები (%)'],
    # ['ერთიანობის დარბაზი', 'ერთიანობის დარბაზი', 'ხმების გადანაწილება, ერთიანობის დარბაზი (%)'],
    ['საქართველოს გზა', 'საქ-ოს გზა', 'ხმების გადანაწილება, საქართველოს გზა (%)'],
    ['სახალხო პარტია', 'სახალხო პარტია', 'ხმების გადანაწილება, სახალხო პარტია (%)']
  ]
}

  def up
    clone_event_id = 31 # 2012 parl party list
    clone_ind_event_id = 31 # 2012 parl party list
    clone_core_ind_id = 59 #unm

    Event.transaction do
      event = Event.clone_from_event(clone_event_id, '2014-06-28')
      event.event_type_id = 5 # local

      if event.present?
        puts "event created with id of #{event.id}"

        # update values
        event.shape_id = 69898
        event.event_translations.each do |trans|
          if trans.locale == 'ka'
            trans.name = '2014 წლის გამგებლის არჩევნების მეორე ტური'
            trans.name_abbrv = '2014 წლის გამგებლის მეორე ტური'
            trans.description = '2014 წლის 28 ივნისის გამგებლის არჩევნების მეორე ტურის შედეგები. 2014 წლის 15 ივნისს 13 ქალაქში ხმების 50%-ზე მეტის მიღება ვერც ერთმა კანდიდატმა შეძლო, რის გამოც მეორე ტური დაინიშნა. გამგებლები არჩეულია 4 წლის ვადით.'
          elsif trans.locale == 'en'
            trans.name = '2014 Governor Runoff Election'
            trans.name_abbrv = '2014 Governor Runoff'
            trans.description = 'The results of the June 28, 2014 runoff election for Governor. For 13 governor races, no candidate received more than 50% of the vote on June 15, 2014 so a runoff was held. Governors are elected for four year terms.'
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
            puts "- found party #{NEW_PARTIES[:en][index][0]}; party id = #{party.id}"
          end

          # now clone the indicators and scales for this new indciator
          puts "-- creating indicators"
          Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

        end

        ################################################
        # load the data
        ################################################
        puts "-> loading data"
        locale = I18n.locale
        I18n.locale = :en
        file_path = "#{Rails.root}/db/load data/2014/upload_2014_official_gamgebeli_runoff.csv"
        Datum.build_from_csv(event.id,
              Datum::DATA_TYPE[:official],
              nil,
              nil,
              Time.now,
              File.new(file_path),
              true
        )
        I18n.locale = locale


        I18n.available_locales.each do |locale|
          JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
          JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
        end


      end
    end
  end

  def down
    Event.transaction do
      event = Event.includes(:event_translations).where(:event_date => '2014-06-28', event_translations: {name: '2014 Runoff Governor Election'}).first
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
