class CoreIndicatorSweeper < ActionController::Caching::Sweeper
  observe CoreIndicator # This sweeper is going to keep an eye on the CoreIndicator model

  # If our sweeper detects that a CoreIndicator was created call this
  def after_create(core_indicator)
    expire_cache_for(core_indicator)
  end

  # If our sweeper detects that a CoreIndicator was updated call this
  def after_update(core_indicator)
    expire_cache_for(core_indicator)
  end

  # If our sweeper detects that a CoreIndicator was deleted call this
  def after_destroy(core_indicator)
    expire_cache_for(core_indicator)
  end

  private
  def expire_cache_for(core_indicator)
Rails.logger.debug "............... clearing all cache for events that have this indicator"
    # get list of events that use this indicator & clear cache for each event
    inds = Indicator.select('event_id').where(:core_indicator_id => core_indicator.id)
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
