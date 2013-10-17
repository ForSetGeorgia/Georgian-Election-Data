class RemoveValidationErrorInds < ActiveRecord::Migration
  require 'json_cache'
  def up
    # for each election remove these indicators

    event_names = ['2012 Parliamentary - Party List', '2012 Parliamentary - Majoritarian']
    events = Event.includes(:event_translations).where(:event_translations => {:name => event_names, :locale => 'en'})

    core_names = ['Precincts with Validation Errors (%)', 'Precincts with Validation Errors (#)', 'Average Number of Validation Errors', 'Number of Validation Errors']
    cores = CoreIndicatorTranslation.where(:name => core_names, :locale => 'en')

    if cores.present? && events.present?
    
      Indicator.transaction do
        Indicator.where(:event_id => events.map{|x| x.id}, :core_indicator_id => cores.map{|x| x.core_indicator_id}).destroy_all
      end 
      
      # clear cache
      events.each do |event|
        JsonCache.clear_all_data(event.id)
      end
      
    end
    
  end

  def down
    # do nothing
  end
end
