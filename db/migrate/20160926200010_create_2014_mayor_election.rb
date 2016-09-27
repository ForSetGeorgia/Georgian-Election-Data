class Create2014MayorElection < ActiveRecord::Migration
# the ids are the election party id, not related to any id in the system
# parties = [
#     {id: 1, name: 'Non-Parliamentary Opposition', status: 'new'},
#     {id: 2, name: 'Armed Veterans Patriots', status: 'new'},
#     {id: 3, name: 'United Opposition', status: 'exists'},
###     {id: 4, name: 'National Democratic Party of Georgia', status: 'exists'},
#     {id: 5, name: 'United National Movement', status: 'exists'},
#     {id: 6, name: 'Greens Party', status: 'new'},
#     {id: 7, name: 'Name of the Lord', status: 'new'},
#     {id: 8, name: 'Alliance of Patriots', status: 'new'},
#     {id: 9, name: 'Self-governance to People', status: 'new'},
#     {id: 10, name: 'People's Party, status: 'exists'},
#     {id: 11, name: 'Reformers', status: 'new'},
#     {id: 12, name: 'Our Georgia', status: 'new'},
#     {id: 13, name: 'Future Georgia', status: 'exists'},
#     {id: 14, name: 'Georgian Party', status: 'new'},
###     {id: 15, name: 'People's Movement', status: 'new'},
###     {id: 16, name: 'Christian Democrats', status: 'new'},
#     {id: 17, name: 'Unity Hall', status: 'new'},
#     {id: 18, name: 'Way of Georgia', status: 'new'},
###     {id: 19, name: 'Freedom', status: 'exists'},
#     {id: 20, name: 'Labour', status: 'exists'},
#     {id: 26, name: 'Party of People', status: 'new'},
#     {id: 30, name: 'Merab Kostava Society', status: 'exists'},
#     {id: 36, name: 'Labour Council', status: 'exists'},
#     {id: 41, name: 'Georgian Dream', status: 'exists'}
#   ]

# ids are core ids - names are just there to indicate what the party is
EXISTING_PARTIES = [
  [60, "United Opposition"],
#  [43, "National Democratic Party of Georgia"],
  [59, "United National Movement"],
  [71, "People's Party"],
  [25, "Future Georgia"],
 # [24, 'Freedom'],
  [36, "Labour"],
  [72, "Merab Kostava Society"],
  [73, 'Labour Council'],
  [74, "Georgian Dream"]
]

NEW_PARTIES = {
  :en => [
    ['Non-Parliamentary Opposition', 'Non-Parl Opp', 'Vote share Non-Parliamentary Opposition (%)', '#545f52'],
    ['Armed Veterans Patriots', 'Armed Vets', 'Vote share Armed Veterans Patriots (%)', '#554d45'],
    ['Greens Party', 'Greens Party', 'Vote share Greens Party (%)', '#458a40'],
    ['Name of the Lord', 'Name of Lord', 'Vote share Name of the Lord (%)', '#3a0c17'],
    ['Alliance of Patriots', 'Alliance', 'Vote share Alliance of Patriots (%)', '#C26254'],
    ['Self-governance to People', 'Self-gov', 'Vote share Self-governance to People (%)', '#c6cc88'],
    ['Reformers', 'Reformers', 'Vote share Reformers (%)', '#53501a'],
    ['Our Georgia', 'Our Georgia', 'Vote share Our Georgia (%)', '#975710'],
    ['Georgian Party', 'Geo Party', 'Vote share Georgian Party (%)', '#8e9b8b'],
#    ['People\'s Movement', 'People\'s Mvmnt', 'Vote share People\'s Movement (%)', '#b8afba'],
#    ['Christian Democrats', 'Christian Dems', 'Vote share Christian Democratic Party (%)', '#ca9c6c'],
    ['Unity Hall', 'Unity Hall', 'Vote share Unity Hall (%)', '#372a24'],
    ['Way of Georgia', 'Way of Georgia', 'Vote share Way of Georgia (%)', '#9b8b8e'],
    ['Party of People', 'Party of People', 'Vote share Party of People (%)', '#231331']
  ],
  :ka => [
    ['არასაპარლამენტო ოპოზიცია', 'არასაპარლამენტო ოპ.', 'ხმების გადანაწილება, არასაპარლამენტო ოპოზიცია (%)'],
    ['საქართველოს ძალოვან ვეტერანთა და პატრიოტთა პოლიტიკური მოძრაობა', 'ვეტერანები', 'ხმების გადანაწილება, საქართველოს ძალოვან ვეტერანთა და პატრიოტთა პოლიტიკური მოძრაობა (%)'],
    ['მწვანეთა პარტია', 'მწვანეები', 'ხმების გადანაწილება, მწვანეთა პარტია (%)'],
    ['უფლის სახელით', 'უფლის სახელით', 'ხმების გადანაწილება, უფლის სახელით (%)'],
    ['საქართველოს პატრიოტთა ალიანსი', 'ალიანსი', 'ხმების გადანაწილება, საქართველოს პატრიოტთა ალიანსი (%)'],
    ['თვითმმართველობა ხალხს', 'თვითმ. ხალხს', 'ხმების გადანაწილება, თვითმმართველობა ხალხს (%)'],
    ['რეფორმატორები', 'რეფორმატორები', 'ხმების გადანაწილება, რეფორმატორები (%)'],
    ['ჩვენი საქართველო', 'ჩვენი საქართ.', 'ხმების გადანაწილება, ჩვენი საქართველო (%)'],
    ['ქართული პარტია', 'ქართ. პარტია', 'ხმების გადანაწილება, ქართული პარტია (%)'],
#    ['სახალხო მოძრაობა', 'სახალხო მოძ.', 'ხმების გადანაწილება, სახალხო მოძრაობა (%)'],
#    ['ქრისტიან დემოკრატები', 'ქრისტიან დემოკრატები', 'ხმების გადანაწილება, ქრისტიან დემოკრატები (%)'],
    ['ერთიანობის დარბაზი', 'ერთიანობის დარბაზი', 'ხმების გადანაწილება, ერთიანობის დარბაზი (%)'],
    ['საქართველოს გზა', 'საქ-ოს გზა', 'ხმების გადანაწილება, საქართველოს გზა (%)'],
    ['სახალხო პარტია', 'სახალხო პარტია', 'ხმების გადანაწილება, სახალხო პარტია (%)']
  ]
}

  def up
    clone_event_id = 11 # 2010 mayor
    clone_ind_event_id = 31 # 2012 parl party list
    clone_core_ind_id = 28 #unm - ugulava

    Event.transaction do
      event = Event.clone_from_event(clone_event_id, '2014-06-15')

      if event.present?
        puts "event created with id of #{event.id}"

        # update values
        event.shape_id = 69898
        event.event_translations.each do |trans|
          trans.name = trans.name.gsub('2010', '2014').gsub('Tbilisi ', '').gsub('თბილისის ', '')
          trans.name_abbrv = trans.name_abbrv.gsub('2010', '2014').gsub('Tbilisi ', '').gsub('თბილისის ', '')
          trans.description = trans.description.gsub('May 30, 2010', 'June 15, 2014').gsub('2010 წლის 30 მაისის', '2014 წლის 15 ივნისის')
                                                .gsub('The Tbilisi Mayor is elected', 'Mayors are elected')
                                                .gsub(' This was the first ever direct election for Mayor of Tbilisi.', '')
                                                .gsub('Mayor of Tbilisi', 'Mayor').gsub('Tbilisi Mayor', 'Mayor')
                                                .gsub(' თბილისის მერი პირდაპირი არჩევნების წესით პირველად იქნა არჩეული.', '')
                                                .gsub('თბილისის მერის', 'მერის').gsub('თბილისის მერი', 'მერი')
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
          event.clone_event_components(clone_ind_event_id, core_indicator_ids: inds, clone_indicators: false)
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
          # puts "-- creating indicators"
          # Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event.id, party.id)

        end


        ################################################
        # the list of indicators are not acurate, so load the csv file to fix it all
        # csv file was downloaded from the admin section after the above was completed
        # and updated to fix the errors
        ################################################
        locale = I18n.locale
        puts "locale was #{locale}, now en"
        I18n.locale = :en
        puts "---------------"
        puts "- loading indicators from csv file"
        file_path = "#{Rails.root}/db/load data/2014/Indicator_Names_Scales_for_2014_Mayor.csv"
        Indicator.build_from_csv(File.new(file_path), true)
        puts "- LOADING DONE!!!!"
        puts "---------------"


        ################################################
        # load the data
        ################################################
        file_path = "#{Rails.root}/db/load data/2014/upload_2014_official_mayor.csv"
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
      event = Event.includes(:event_translations).where(:event_date => '2014-06-15', event_translations: {name: '2014 Mayor Election'}).first
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
