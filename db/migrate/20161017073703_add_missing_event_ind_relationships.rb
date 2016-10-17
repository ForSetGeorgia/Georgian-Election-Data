class AddMissingEventIndRelationships < ActiveRecord::Migration
  def up
  require 'json_cache'
  # - add missing event ind relationships to the following:
  #   - invalid ballots (86)
  #   - more ballots than votes (99)
  #   - more votes than ballots (103)
  #   - vpm 8-12 (2)
  #   - vpm 12-17 (4)
  #   - vpm 17-20 (6)
  #   elections:
  #   - all 2014, all 2016

    EventIndicatorRelationship.transaction do
      core_indicator_ids = [86,99,103,2,4,6]
      event_years = [2014,2016]
      clone_event_id = 38 # 2013 presidential
      # get all events in 2014/2016 that are not voters lists
      event_ids = Event.where(['year(event_date) in (?) and event_type_id != 2', event_years]).pluck(:id)

      if event_ids.present?
        # clone each indicator relationship for each indicator and each event
        core_indicator_ids.each do |core_indicator_id|
          puts "--------------"
          puts "core indicator: #{core_indicator_id} "
          event_ids.each do |event_id|
            # check to see if this relationship already exists
            # if not, create it
            if EventIndicatorRelationship.where(event_id: event_id, core_indicator_id: core_indicator_id).count == 0
              puts "- event id #{event_id}"
              EventIndicatorRelationship.clone_from_core_indicator(clone_event_id, core_indicator_id, event_id, core_indicator_id)
            end
          end
        end
      else
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts "WARNING - COULD NOT FIND ANY EVENTS"
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      end

      # clear the cache for each event
      if event_ids.present?
        event_ids.each do |event_id|
          JsonCache.clear_data_files(event_id)
        end
      end
    end
  end

  def down
    puts "do nothing"
  end
end
