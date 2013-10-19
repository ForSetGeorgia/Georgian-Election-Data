# encoding: UTF-8
class Create2013PartyCandidateIndicators < ActiveRecord::Migration
  def up
    event = Event.joins(:event_translations).where(:event_translations => {:name => '2013 Presidential', :locale => 'en'})    
    event_id = event.first.id if event.present?
    clone_event = Event.joins(:event_translations).where(:event_translations => {:name => '2012 Parliamentary - Party List', :locale => 'en'})    
    clone_event_id = clone_event.first.id if clone_event.present?
    clone_core_ind_id = 59 #unm
    
    if event_id.present? && clone_event_id.present?
      puts "found event and clone event"
      CoreIndicator.transaction do

        # candidates for initiative group
        puts "################################"
        puts "initiative group candidates"
        puts "################################"
        init_group = CoreIndicator.joins(:core_indicator_translations).where(:core_indicator_translations => {:name => 'Initiative Group', :locale => 'en'})
        
        if init_group.blank?
          puts "- could not find party 'Initiative Group'"
          raise ActiveRecord::Rollback 
          return                 
        end
        
        candidates = {
          :en => [['Tamaz Bibiluri', 'Bibiluri', 'Vote share Tamaz Bibiluri (%)'],
                  ['Giorgi Liluashvili', 'Liluashvili', 'Vote share Giorgi Liluashvili (%)'],
                  ['Nino Chanishvili', 'Chanishvili', 'Vote share Nino Chanishvili (%)'],
                  ['Teimuraz Bobokhidze', 'Bobokhidze', 'Vote share Teimuraz Bobokhidze (%)'],
                  ['Levan Chachua', 'Chachua', 'Vote share Levan Chachua (%)'],
                  ['Nestan Kirtadze', 'Kirtadze', 'Vote share Nestan Kirtadze (%)'],
                  ['Giorgi Chikhladze', 'Chikhladze', 'Vote share Giorgi Chikhladze (%)'],
                  ['Mikheil Saluashvili', 'Saluashvili', 'Vote share Mikheil Saluashvili (%)'],
                  ['Kartlos Gharibashvili', 'Gharibashvili', 'Vote share Kartlos Gharibashvili (%)'],
                  ['Mamuka Chokhonelidze', 'Chokhonelidze', 'Vote share Mamuka Chokhonelidze (%)'],
                  ['Avtandil Margiani', 'Margiani', 'Vote share Avtandil Margiani (%)'],
                  ['Nugzar Avaliani', 'Avaliani', 'Vote share Nugzar Avaliani (%)'],
                  ['Mamuka Melikishvili', 'Melikishvili', 'Vote share Mamuka Melikishvili (%)']],
          :ka => [['თამაზ ბიბილური', 'ბიბილური', 'ხმების გადანაწილება, თამაზ ბიბილური (%)'],
                  ['გიორგი ლილუაშვილი', 'ლილუაშვილი', 'ხმების გადანაწილება, გიორგი ლილუაშვილი (%)'],
                  ['ნინო ჭანიშვილი', 'ჭანიშვილი', 'ხმების გადანაწილება, ნინო ჭანიშვილი (%)'],
                  ['თეიმურაზ ბობოხიძე', 'ბობოხიძე', 'ხმების გადანაწილება, თეიმურაზ ბობოხიძე (%)'],
                  ['ლევან ჩაჩუა', 'ჩაჩუა', 'ხმების გადანაწილება, ლევან ჩაჩუა (%)'],
                  ['ნესტან კირთაძე', 'კირთაძე', 'ხმების გადანაწილება, ნესტან კირთაძე (%)'],
                  ['გიორგი ჩიხლაძე', 'ჩიხლაძე', 'ხმების გადანაწილება, გიორგი ჩიხლაძე (%)'],
                  ['მიხეილ სალუაშვილი', 'სალუაშვილი', 'ხმების გადანაწილება, მიხეილ სალუაშვილი (%)'],
                  ['ქართლოს ღარიბაშვილი', 'ღარიბაშვილი', 'ხმების გადანაწილება, ქართლოს ღარიბაშვილი (%)'],
                  ['მამუკა ჭოხონელიძე', 'ჭოხონელიძე', 'ხმების გადანაწილება, მამუკა ჭოხონელიძე (%)'],
                  ['ავთანდილ მარგიანი', 'მარგიანი', 'ხმების გადანაწილება, ავთანდილ მარგიანი (%)'],
                  ['ნუგზარ ავალიანი', 'ავალიანი', 'ხმების გადანაწილება, ნუგზარ ავალიანი (%)'],
                  ['მამუკა მელიქიშვილი', 'მელიქიშვილი', 'ხმების გადანაწილება, მამუკა მელიქიშვილი (%)']]
        }      
        
        
        (0..candidates[:en].length-1).each do |index|
          puts "- creating candidate #{candidates[:en][index][0]}"
          core = CoreIndicator.new(:indicator_type_id => 2, :number_format => '%')
          core.parent_id = init_group.first.id
          core.core_indicator_translations.build(:locale => 'en', :name => candidates[:en][index][0],
            :name_abbrv => candidates[:en][index][1], :description => candidates[:en][index][2])
          core.core_indicator_translations.build(:locale => 'ka', :name => candidates[:ka][index][0],
            :name_abbrv => candidates[:ka][index][1], :description => candidates[:ka][index][2])
          core.save
            
            
          # now clone the indicators and scales for this new indciator
          puts "-- creating indicators"
          Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event_id, core.id)
            
          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event_id, core.id)
            
        end
        

        # now candidates tied to parties
        puts "################################"
        puts 'add candidates to existing parties'
        puts "################################"
        parties = ['Christian-Democratic Movement', 'Movement for Fair Georgia', 'Georgian Dream', 'Labour', 'People\'s Party', 'United National Movement']
        candidates = {
          :en => [['Giorgi Targamadze', 'Targamadze', 'Vote share Giorgi Targamadze (%)'],
                  ['Sergo Javakhidze', 'Javakhidze', 'Vote share Sergo Javakhidze (%)'],
                  ['Giorgi Margvelashvili', 'Margvelashvili', 'Vote share Giorgi Margvelashvili (%)'],
                  ['Shalva Natelashvili', 'Natelashvili', 'Vote share Shalva Natelashvili (%)'],
                  ['Koba Davitashvili', 'Davitashvili', 'Vote share Koba Davitashvili (%)'],
                  ['Davit Bakradze', 'Bakradze', 'Vote share Davit Bakradze (%)']],
          :ka => [['გიორგი თარგამაძე', 'თარგამაძე', 'ხმების გადანაწილება, გიორგი თარგამაძე (%)'],
                  ['სერგო ჯავახიძე', 'ჯავახიძე', 'ხმების გადანაწილება, სერგო ჯავახიძე (%)'],
                  ['გიორგი მარგველაშვილი', 'მარგველაშვილი', 'ხმების გადანაწილება, გიორგი მარგველაშვილი (%)'],
                  ['შალვა ნათელაშვილი', 'ნათელაშვილი', 'ხმების გადანაწილება, შალვა ნათელაშვილი (%)'],
                  ['კობა დავითაშვილი', 'დავითაშვილი', 'ხმების გადანაწილება, კობა დავითაშვილი (%)'],
                  ['დავით ბაქრაძე', 'ბაქრაძე', 'ხმების გადანაწილება, დავით ბაქრაძე (%)']]
        }
        (0..candidates[:en].length-1).each do |index|
          puts "- creating candidate #{candidates[:en][index][0]}"
          party = CoreIndicator.joins(:core_indicator_translations).where(:core_indicator_translations => {:name => parties[index], :locale => 'en'})
          if party.blank?
            puts "- could not find party '#{parties[index]}'"
            raise ActiveRecord::Rollback 
            return                 
          end

          exists = CoreIndicatorTranslation.where(:locale => 'en', :name => candidates[:en][index][0])
          if exists.present?
            puts "-- already exists"
            core = CoreIndicator.find_by_id(exists.first.core_indicator_id)          
          else
            core = CoreIndicator.new(:indicator_type_id => 2, :number_format => '%')
            core.parent_id = party.first.id
            core.core_indicator_translations.build(:locale => 'en', :name => candidates[:en][index][0],
              :name_abbrv => candidates[:en][index][1], :description => candidates[:en][index][2])
            core.core_indicator_translations.build(:locale => 'ka', :name => candidates[:ka][index][0],
              :name_abbrv => candidates[:ka][index][1], :description => candidates[:ka][index][2])
            core.save
          end
            
          # now clone the indicators and scales for this new indciator
          puts "-- creating indicators"
          Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event_id, core.id)
            
          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event_id, core.id)
            
        end
        

        # create new parties and add candidatess
        puts "################################"
        puts 'create parties and candidates'
        puts "################################"

        parties = {
          :en => [['Union of Georgian Traditionalists', 'Geo Traditionalists', 'Vote share Union of Georgian Traditionalists (%)', '#750142'],
                  ['Democratic Movement - United Georgia', 'United Geo', 'Vote share Democratic Movement - United Georgia (%)', '#079fe2'],
                  ['European Democrats', 'Euro Democrats', 'Vote share European Democrats (%)', '#2A0E74'],
                  ['Christian-Democratic People\'s Party', 'CD People\'s Party', 'Vote share Christian-Democratic People\'s Party (%)', '#9aaa38']],
          :ka => [['ქართველ ტრადიციონალისტთა კავშირი', 'ქტკ', 'ხმების გადანაწილება, ქართველ ტრადიციონალისტთა კავშირი (%)'],
                  ['დემოკრატიული მოძრაობა - ერთიანი საქართველო', 'ერთიანი საქართველო', 'ხმების გადანაწილება, დემოკრატიული მოძრაობა - ერთიანი საქართველო (%)'],
                  ['საქართველოს ევროპელი დემოკრატები', 'ევროპელი დემოკრატები', 'ხმების გადანაწილება, საქართველოს ევროპელი დემოკრატები (%)'],
                  ['ქრისტიან-დემოკრატიული სახალხო პარტია', 'ქრისტიან-დემოკრატიული სახალხო პარტია', 'ხმების გადანაწილება, ქრისტიან-დემოკრატიული სახალხო პარტია (%)']]
        }
        candidates = {
          :en => [['Akaki Asatiani', 'Asatiani', 'Vote share Akaki Asatiani (%)'],
                  ['Nino Burjanadze', 'Burjanadze', 'Vote share Nino Burjanadze (%)'],
                  ['Zurab Kharatishvili', 'Kharatishvili', 'Vote share Zurab Kharatishvili (%)'],
                  ['Teimuraz Mzhavia', 'Mzhavia', 'Vote share Teimuraz Mzhavia (%)']],
                  
          :ka => [['აკაკი ასათიანი', 'ასათიანი', 'ხმების გადანაწილება, აკაკი ასათიანი (%)'],
                  ['ნინო ბურჯანაძე', 'ბურჯანაძე', 'ხმების გადანაწილება, ნინო ბურჯანაძე (%)'],
                  ['ზურაბ ხარატიშვილი', 'ხარატიშვილი', 'ხმების გადანაწილება, ზურაბ ხარატიშვილი (%)'],
                  ['თეიმურაზ მჟავია', 'მჟავია', 'ხმების გადანაწილება, თეიმურაზ მჟავია (%)']]
        }

        (0..candidates[:en].length-1).each do |index|
          puts "- creating party #{parties[:en][index][0]}"
          party = CoreIndicator.new(:indicator_type_id => 2, :number_format => '%', :color => parties[:en][index][3])
          party.core_indicator_translations.build(:locale => 'en', :name => parties[:en][index][0],
            :name_abbrv => parties[:en][index][1], :description => parties[:en][index][2])
          party.core_indicator_translations.build(:locale => 'ka', :name => parties[:ka][index][0],
            :name_abbrv => parties[:ka][index][1], :description => parties[:ka][index][2])
          party.save


          puts "- creating candidate #{candidates[:en][index][0]}"

          exists = CoreIndicatorTranslation.where(:locale => 'en', :name => candidates[:en][index][0])
          if exists.present?
            puts "-- already exists"
            core = CoreIndicator.find_by_id(exists.first.core_indicator_id)          
          else
            core = CoreIndicator.new(:indicator_type_id => 2, :number_format => '%')
            core.parent_id = party.id
            core.core_indicator_translations.build(:locale => 'en', :name => candidates[:en][index][0],
              :name_abbrv => candidates[:en][index][1], :description => candidates[:en][index][2])
            core.core_indicator_translations.build(:locale => 'ka', :name => candidates[:ka][index][0],
              :name_abbrv => candidates[:ka][index][1], :description => candidates[:ka][index][2])
            core.save
          end
            
          # now clone the indicators and scales for this new indciator
          puts "-- creating indicators"
          Indicator.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event_id, core.id)
            
          # now clone the relationships for this new indciator
          puts "-- creating relationships"
          EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, clone_core_ind_id, event_id, core.id)
            
        end

        I18n.available_locales.each do |locale|
      		JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
      		JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
        end


      end
    end
  end

  def down
    event = Event.joins(:event_translations).where(:event_translations => {:name => '2013 Presidential', :locale => 'en'})    
    event_id = event.first.id if event.present?
    
    if event_id.present?
      # delete all indicators of type 'result' for this event that are not being used in another event
      CoreIndicator.transaction do
			  ids = CoreIndicator.select("distinct core_indicators.id").joins(:indicators)
					  .where(:indicators => {:event_id => event_id}, :core_indicators => {:indicator_type_id => 2})

        keep_ids = CoreIndicator.select("distinct core_indicators.id").joins(:indicators)
            .where("indicators.event_id != ? and core_indicators.indicator_type_id = 2", event_id)

        if ids.present? && keep_ids.present?
          puts "ids has #{ids.length} indicators; to keep has #{keep_ids} indicators"

          everything = []
          indicators_only = []
          ids.each do |id|
            if keep_ids.index{|x| x.id == id.id}.present?
              indicators_only << id.id
            else
              everything << id.id
            end
          end
          
          puts "deleting indicators only for #{indicators_only.length} cores: #{indicators_only}"
          puts "deleting everything for #{everything.length} cores: #{everything}"
          
          Indicator.where(:event_id => event_id, :core_indicator_id => indicators_only).destroy_all
          EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => indicators_only).destroy_all
          
          CoreIndicator.where(:id => everything).destroy_all        
        end        
        
        I18n.available_locales.each do |locale|
      		JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
      		JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
        end
        
      end      
    end
  end
end
