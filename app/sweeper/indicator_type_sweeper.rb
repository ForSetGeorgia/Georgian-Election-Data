class IndicatorTypeSweeper < ActionController::Caching::Sweeper
  observe IndicatorType # This sweeper is going to keep an eye on the IndicatorType model

  # If our sweeper detects that a IndicatorType was created call this
  def after_create(indicator_type)
#    expire_cache_for(indicator_type)
  end

  # If our sweeper detects that a IndicatorType was updated call this
  def after_update(indicator_type)
    expire_cache_for(indicator_type)
  end

  # If our sweeper detects that a IndicatorType was deleted call this
  def after_destroy(indicator_type)
    expire_cache_for(indicator_type)
  end

  private
  def expire_cache_for(indicator_type)
Rails.logger.debug "............... clearing all cache for events that have this indicator type"
    # get list of core indicators that are in this type
    core_ids = CoreIndicator.select('id').where(:indicator_type_id => indicator_type.id)
    
    inds = Indicator.select('event_id').where(:core_indicator_id => core_ids.map{|x| x.id})
    if inds.present?
      inds.map{|x| x.event_id}.uniq.each do |event_id|
    		JsonCache.clear_all_data(event_id)
      end
    end

    # remove 
    I18n.available_locales.each do |locale|
  		JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
  		JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
    end

  end
end
