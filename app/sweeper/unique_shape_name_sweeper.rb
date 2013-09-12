class UniqueShapeNameSweeper < ActionController::Caching::Sweeper
  observe UniqueShapeName # This sweeper is going to keep an eye on the UniqueShapeName model

  # If our sweeper detects that a UniqueShapeName was created call this
  def after_create(unique_shape_name)
    expire_cache_for(unique_shape_name)
  end

  # If our sweeper detects that a UniqueShapeName was updated call this
  def after_update(unique_shape_name)
    expire_cache_for(unique_shape_name)
  end

  # If our sweeper detects that a UniqueShapeName was deleted call this
  def after_destroy(unique_shape_name)
    expire_cache_for(unique_shape_name)
  end

  private
  def expire_cache_for(unique_shape_name)
Rails.logger.debug "............... clearing shape profile cache because of change to unique shape name"
		
    I18n.available_locales.each do |locale|
  		JsonCache.clear_data_file("profiles/district_events_#{locale}")
  		JsonCache.clear_data_file("profiles/district_events_table_#{locale}")
    end
		
  end
end
