# encoding: UTF-8
class UpdateValErrIndName < ActiveRecord::Migration
  def up
    CoreIndicatorTranslation.transaction do

      # Average Number of Missing Ballots
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Average Number of Missing Ballots"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Average Number of Validation Errors'
      trans.name_abbrv = 'Avg Num Validation Errors'
      trans.description = 'Average Number of Validation Errors'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'შემოწმებისას გამოვლენილი უზუსტობების საშუალო რაოდენობა'
      trans.name_abbrv = 'შემოწმებისას გამოვლენილი უზუსტობების საშ. რაოდენობა'
      trans.description = 'შემოწმებისას გამოვლენილი უზუსტობების საშუალო რაოდენობა'
      trans.save
      
    
      # Number of Missing Ballots
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Number of Missing Ballots"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Number of Validation Errors'
      trans.name_abbrv = 'Validation Errors (#)'
      trans.description = 'Number of Validation Errors'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'შემოწმებისას გამოვლენილი უზუსტობების რაოდენობა'
      trans.name_abbrv = 'შემოწმებისას გამოვლენილი უზუსტობები (#)'
      trans.description = 'შემოწმებისას გამოვლენილი უზუსტობების რაოდენობა'
      trans.save
      
      
      # Precincts with Missing Ballots (#)
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Precincts with Missing Ballots (#)"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Precincts with Validation Errors (#)'
      trans.name_abbrv = 'Validation Errors (#)'
      trans.description = 'Precincts with Validation Errors'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'საარჩვნო უბნები შემოწმებისას გამოვლენილი უზუსტობებით (#)'
      trans.name_abbrv = 'შემოწმებისას გამოვლენილი უზუსტობები (#)'
      trans.description = 'საარჩვნო უბნები შემოწმებისას გამოვლენილი უზუსტობებით (#)'
      trans.save
      

      # Precincts with Missing Ballots (%)
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Precincts with Missing Ballots (%)"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Precincts with Validation Errors (%)'
      trans.name_abbrv = 'Validation Errors (%)'
      trans.description = 'Precincts with Validation Errors'
      trans.summary = 'Percentage of precincts in a district where the sum of the counted votes do not equal the number of signatures in the registration book minus the number of invalid ballots.'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'საარჩვნო უბნები შემოწმებისას გამოვლენილი უზუსტობებით (%)'
      trans.name_abbrv = 'შემოწმებისას გამოვლენილი უზუსტობები (%)'
      trans.description = 'საარჩვნო უბნები შემოწმებისას გამოვლენილი უზუსტობებით (%)'
      trans.summary = 'ოლქში იმ საარჩევნო უბნების პროცენტული რაოდენობა, სადაც დათვლილი ხმების ჯამი არ უტოლდება სარეგისტრაციო წიგნში ხელმოწერების რაოდენობას გამოკლებული ბათილი ბიულეტენები.'
      trans.save
      

      # clear the cache
      # - get events that use this indicator
      inds = Indicator.select('distinct event_id').where(:core_indicator_id => core.id)
      inds.each do |ind|
  		  JsonCache.clear_all_data(ind.event_id)
      end
      I18n.available_locales.each do |locale|
    		JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
    		JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
      end

    end
  end




  def down
    CoreIndicatorTranslation.transaction do

      # Average Number of Missing Ballots
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Average Number of Validation Errors"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Average Number of Missing Ballots'
      trans.name_abbrv = 'Avg Num Missing Ballots'
      trans.description = 'Average Number of Missing Ballots'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'დაკარგული ბიულეტენების საშუალო რაოდენობა'
      trans.name_abbrv = 'დაკარგული ბიულეტენების საშ. რაოდენობა'
      trans.description = 'დაკარგული ბიულეტენების საშუალო რაოდენობა'
      trans.save
      
    
      # Number of Missing Ballots
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Number of Validation Errors"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Number of Missing Ballots'
      trans.name_abbrv = 'Missing Ballots (#)'
      trans.description = 'Number of Missing Ballots'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'დაკარგული ბიულეტენების რაოდენობა'
      trans.name_abbrv = 'დაკარგული ბიულეტენები (#)'
      trans.description = 'დაკარგული ბიულეტენების რაოდენობა'
      trans.save
      
      
      # Precincts with Missing Ballots (#)
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Precincts with Validation Errors (#)"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Precincts with Missing Ballots (#)'
      trans.name_abbrv = 'Missing Ballots (#)'
      trans.description = 'Precincts with Missing Ballots'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'საარჩევნო უბნები, რომლებსაც აქვთ (#) დაკარგული ბიულეტენი'
      trans.name_abbrv = 'დაკარგული ბიულეტენები (#)'
      trans.description = 'საარჩევნო უბნები, რომლებსაც აქვთ (#) დაკარგული ბიულეტენი'
      trans.save
      

      # Precincts with Missing Ballots (%)
      core = CoreIndicator.select('core_indicators.id').joins(:core_indicator_translations).where('core_indicator_translations.name = "Precincts with Validation Errors (%)"').first
      # en
      trans = CoreIndicatorTranslation.where(:locale => 'en', :core_indicator_id => core.id).first
      trans.name = 'Precincts with Missing Ballots (%)'
      trans.name_abbrv = 'Missing Ballots (%)'
      trans.description = 'Precincts with Missing Ballots'
      trans.summary = 'Percentage of precincts in a district where the signatures in the registration book do not equal the number of ballots in the ballot box.'
      trans.save
            
      # ka
      trans = CoreIndicatorTranslation.where(:locale => 'ka', :core_indicator_id => core.id).first
      trans.name = 'საარჩევნო უბნები, რომლებსაც აქვთ (%) დაკარგული ბიულეტენი'
      trans.name_abbrv = 'დაკარგული ბიულეტენები (%)'
      trans.description = 'საარჩევნო უბნები, რომლებსაც აქვთ (%) დაკარგული ბიულეტენი'
      trans.summary = 'ოლქში საარჩევნო უბნების რაოდენობა, სადაც სარეგისტრაციო წიგნში ხელმოწერების რაოდენობა არ უტოლდება საარჩევნო ყუთში განთავსებულ ბიულეტენთა რაოდენობას.'
      trans.save
      


      # clear the cache
      # - get events that use this indicator
      inds = Indicator.select('distinct event_id').where(:core_indicator_id => core.id)
      inds.each do |ind|
  		  JsonCache.clear_all_data(ind.event_id)
      end
      I18n.available_locales.each do |locale|
    		JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
    		JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
      end

    end
  end
end
