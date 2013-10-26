# encoding: UTF-8
class Party2013Desc < ActiveRecord::Migration
  def up
    CoreIndicatorTranslation.transaction do
    
      ###############################
      # Union of Georgian Traditionalists
      id = CoreIndicatorTranslation.select('core_indicator_id').where(:name => 'Union of Georgian Traditionalists')    
      if id.present?
        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'en')
        if trans.present?
          trans.first.summary = 'Founded in 1990
          
Political views: Center right

The chairman of the party is Akaki Asatiani'

          trans.first.save
        end

        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'ka')
        if trans.present?
          trans.first.summary = 'დაარსდა 1990 წელს
          
მიმართულება: მემარჯვენე-ცენტრისტული

პარტიის თავმჯდომარეა აკაკი ასათიანი'

          trans.first.save
        end
      end


      ###############################
      # Democratic Movement - United Georgia
      id = CoreIndicatorTranslation.select('core_indicator_id').where(:name => 'Democratic Movement - United Georgia')    
      if id.present?
        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'en')
        if trans.present?
          trans.first.summary = 'Founded in 2008

Political views: Center right

The chairwoman of the party Nino Burjanadze'

          trans.first.save
        end

        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'ka')
        if trans.present?
          trans.first.summary = 'დაარსდა 2008 წელს

მიმართულება: მემარჯვენე-ცენტრისტული

პარტიის თავმჯდომარეა ნინო ბურჯანაძე'

          trans.first.save
        end
      end



      ###############################
      # European Democrats
      id = CoreIndicatorTranslation.select('core_indicator_id').where(:name => 'European Democrats')    
      if id.present?
        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'en')
        if trans.present?
          trans.first.summary = 'The successor of political party "We Ourselves"
          
Founded in 2006

Political views: Center right

The chairman of the party is Paata Davitaia'

          trans.first.save
        end

        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'ka')
        if trans.present?
          trans.first.summary = 'დაარსდა 2006 წელს

მოქალაქეთა პოლიტიკური გაერთიანების "ჩვენ თვითონ" სამართალმემკვიდრე

მიმართულება: მემარჯვენე-ცენტრისტული

თავმჯდომარე პაატა დავითაია'

          trans.first.save
        end
      end



      ###############################
      # Christian-Democratic People's Party
      id = CoreIndicatorTranslation.select('core_indicator_id').where(:name => 'Christian-Democratic People\'s Party')    
      if id.present?
        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'en')
        if trans.present?
          trans.first.summary = 'Founded in 2010

Political views: Not indicated

The chairman of the party is Mamuka Khimshiashvili'

          trans.first.save
        end

        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'ka')
        if trans.present?
          trans.first.summary = 'დაარსდა 2010 წელს

მიმართულება: არ არის მითითებული

თავმჯდომარე მამუკა ხიმშიაშვილი'

          trans.first.save
        end
      end


      ###############################
      # initiative group
      id = CoreIndicatorTranslation.select('core_indicator_id').where(:name => 'initiative group')    
      if id.present?
        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'en')
        if trans.present?
          trans.first.summary = 'Initiative group is a group of individuals, or a single individual, who is running for an elected position independent of any political party.'

          trans.first.save
        end

        trans = CoreIndicatorTranslation.where(:core_indicator_id => id.first.core_indicator_id, :locale => 'ka')
        if trans.present?
          trans.first.summary = 'საინიციატივო ჯგუფად ითვლება ფიზიკურ პირთა ჯგუფი, ან ერთი ფიზიკური პირი, რომლებსაც აქვთ სურვილი განახორციელონ განაცხადის მიხედვით შემოთავაზებული საქმიანობა.'

          trans.first.save
        end
      end




      I18n.available_locales.each do |locale|
    		JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
    		JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
      end

    end
  end

  def down
    # do nothing
  end
end
