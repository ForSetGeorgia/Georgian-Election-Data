class IndicatorSweeper < ActionController::Caching::Sweeper
  observe Indicator # This sweeper is going to keep an eye on the Indicator model

  # If our sweeper detects that a Indicator was created call this
  def after_create(indicator)
    expire_cache_for(indicator)
  end

  # If our sweeper detects that a Indicator was updated call this
  def after_update(indicator)
    expire_cache_for(indicator)
  end

  # If our sweeper detects that a Indicator was deleted call this
  def after_destroy(indicator)
    expire_cache_for(indicator)
  end

  private
  def expire_cache_for(indicator)
Rails.logger.debug "............... clearing all cache for events that have this indicator"
    # get list of events that use this indicator & clear cache for each event
    inds = Indicator.select('event_id').where(:id => indicator.id)
    if inds.present?
      inds.map{|x| x.event_id}.uniq.each do |event_id|
    		JsonCache.clear_all_data(event_id)
      end
    end
  end
end
