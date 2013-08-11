class AddTotTurnPopups < ActiveRecord::Migration
  require 'json_cache'
  def up
    tot_turn_id = 16
    
    EventIndicatorRelationship.transaction do
      # get relationships that exist for summaries that have total turnout #
      relationships = EventIndicatorRelationship.select('distinct event_id, indicator_type_id, sort_order')
        .where('indicator_type_id is not null and related_core_indicator_id = 15')
      
      if relationships.present?
        # add total turnout % to all summary relationships as hidden
        relationships.each do |rel|
          EventIndicatorRelationship.create(:event_id => rel.event_id,
            :indicator_type_id => rel.indicator_type_id,
            :related_core_indicator_id => tot_turn_id,
            :visible => false,
            :sort_order => rel.sort_order + 1
          )
        end  
      end
    end
    JsonCache.clear_all
  end

  def down
    EventIndicatorRelationship
      .where('indicator_type_id is not null and related_core_indicator_id = 16')
      .delete_all
    JsonCache.clear_all
  end
end
