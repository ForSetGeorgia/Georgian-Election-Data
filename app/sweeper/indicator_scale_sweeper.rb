class IndicatorScaleSweeper < ActionController::Caching::Sweeper
  observe IndicatorScale # This sweeper is going to keep an eye on the IndicatorScale model

  # If our sweeper detects that a IndicatorScale was created call this
  def after_create(indicator_scale)
    expire_cache_for(indicator_scale)
  end

  # If our sweeper detects that a IndicatorScale was updated call this
  def after_update(indicator_scale)
    expire_cache_for(indicator_scale)
  end

  # If our sweeper detects that a IndicatorScale was deleted call this
  def after_destroy(indicator_scale)
    expire_cache_for(indicator_scale)
  end

  private
  def expire_cache_for(indicator_scale)
Rails.logger.debug "............... clearing all cache for events that have this indicator"
    # get list of events that use this indicator & clear cache for each event
    inds = Indicator.select('event_id').where(:id => indicator_scale.indicator_id)
    if inds.present?
      inds.map{|x| x.event_id}.uniq.each do |event_id|
    		JsonCache.clear_all_data(event_id)
      end
    end
  end
end
