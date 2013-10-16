class AddEventDefaultInd < ActiveRecord::Migration
  def up
    add_column :events, :default_core_indicator_id, :int
    
    # update voters list with id for total voters
    Event.transaction do
      trans = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Total Voters')
      if trans.present?
        # get all voter list events
        events = Event.select('events.id').joins(:event_type).where('event_types.is_voters_list = 1')      
        if events.present?
          Event.where(:id => events.map{|x| x.id}).update_all(:default_core_indicator_id => trans.first.core_indicator_id)
        end
      end
    end
  end

  def down
    remove_column :events, :default_core_indicator_id
  end
end
