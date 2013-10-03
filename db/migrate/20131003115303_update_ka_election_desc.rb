# encoding: UTF-8
class UpdateKaElectionDesc < ActiveRecord::Migration
  def up
    require 'json_cache'
    
    EventTranslation.transaction do
      names = ["2012 წლის საპარლამენტო არჩევნები - პარტიული სია", "2012 წლის საპარლამენტო არჩევნები - მაჟორიტარული", "2012 წლის აჭარის უმაღლესი საბჭოს არჩევნები - პარტიული სია", "2012 წლის აჭარის უმაღლესი საბჭოს არჩევნები - მაჟორიტარული"]
      EventTranslation.where(:name => names).each do |trans|
        trans.description = trans.description.gsub('წლის 21 მაისის', 'წლის 1 ოქტომბერის') 
        trans.description = trans.description.gsub('წლის 3 ნოემბრის', 'წლის 1 ოქტომბერის') 
        trans.description = trans.description.gsub('2008', '2012')
        trans.save

        JsonCache.clear_all_data(trans.event_id)

      end

      names2 = ["2012 Adjara Supreme Council - Majoritarian", "2012 Adjara Supreme Council - Party List"]
      EventTranslation.where(:name => names2).each do |trans|
        trans.description = trans.description.gsub('November 3, 2008', 'October 1, 2012') 
        trans.save

        JsonCache.clear_all_data(trans.event_id)

      end


      I18n.available_locales.each do |locale|
        Rails.cache.clear("event_menu_json_#{locale.to_s}")
        Rails.cache.fetch("live_event_menu_json_#{locale.to_s}")
      end
    end

  end

  def down
    # do nothing
  end
end
