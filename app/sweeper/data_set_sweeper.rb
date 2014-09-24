class DataSetSweeper < ActionController::Caching::Sweeper
  observe DataSet # This sweeper is going to keep an eye on the DataSet model
  require 'data_archive'

  # If our sweeper detects that a DataSet was created call this
  def after_create(data_set)
    expire_cache_for(data_set)
  end

  # If our sweeper detects that a DataSet was updated call this
  def after_update(data_set)
    expire_cache_for(data_set)
  end

  # If our sweeper detects that a DataSet was deleted call this
  def after_destroy(data_set)
    expire_cache_for(data_set)
  end

  private
  def expire_cache_for(data_set)
## - don't need since each dataset gets their own unique cache folder
#Rails.logger.debug "............... clearing all cache because of change to dataset"
#		JsonCache.clear_all

    # delete the archive for this election
    DataArchive.delete_archive(data_set.event_id)

    # remove 
    I18n.available_locales.each do |locale|
  		JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
  		JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
  		JsonCache.clear_data_file("profiles/district_events_#{locale}")
  		JsonCache.clear_data_file("profiles/district_events_table_#{locale}")
    end

  end
end
