module FindColors

  # get the color codes from core indicators from earlier elections that are no longer being used
  def self.color_codes_no_longer_in_use(event_id, year)

    puts "event id = #{event_id}; max year = #{year}"

    # get core ids for event id
    last_event_core_ids = get_core_inds(event_id)

    puts "- there are #{last_event_core_ids.length} core inds in the event"

    # get all of the old events before some year
    old_event_ids = Event.where(['year(event_date) <= ? and event_type_id != 2', year]).pluck(:id)

    puts "- there are #{old_event_ids.length} events to look through for unused cores"

    # get core ids from early events
    early_core_ids = []

    # for each old event, get the core ids
    old_event_ids.each do |old_event_id|
      early_core_ids << get_core_inds(old_event_id)
    end
    early_core_ids.flatten!.uniq!.sort!

    puts "- there are #{early_core_ids.length} core ids were found"

    # record the ids that are not being used
    unused_ids = early_core_ids - last_event_core_ids

    puts "- there are #{unused_ids.length} core ids that are not being used in this event"

    # now get the core ind names and ids that are not being used
    unused = CoreIndicator.where(id:unused_ids)

    # write it out
    # unused.each{|x| puts "#{x.name} \t || \t #{x.color}"}

    return unused.map{|x| [x.name, x.color]}
  end

private
  def self.get_core_inds(event_id)
    CoreIndicator.joins(:indicators)
        .where(indicator_type_id: 2, ancestry: nil, indicators: {event_id: event_id, ancestry: nil}).pluck(:id)
        .uniq.sort
  end
end