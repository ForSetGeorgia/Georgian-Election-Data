# encoding: UTF-8
class Create2013Election < ActiveRecord::Migration
  def up
    clone_pres_event_id = 2 # 2008 pres
    clone_ind_event_id = 31 # 2012 parl party list

    Event.transaction do
      event = Event.clone_from_event(clone_pres_event_id, '2013-10-27')
      
      puts event.inspect
      
      if event.present?
        puts "event created with id of #{event.id}"
        
        # update values
        event.shape_id = nil
        event.event_translations.each do |trans|
          trans.name = trans.name.gsub('2008', '2013')
          trans.name_abbrv = trans.name_abbrv.gsub('2008', '2013')
          trans.description = trans.description.gsub('January 5, 2008', 'October 27, 2013').gsub('2008 წლის 5 იანვრის', '2013 წლის 27 ოქტომბერის')
        end
        event.save

        # clone event components
        # - get 'other' indciators from 2012 party list
        inds = Indicator.select('distinct core_indicator_id').joins(:core_indicator)
                .where(:indicators => {:event_id => clone_ind_event_id}, :core_indicators => {:indicator_type_id => 1})
                
        if inds.present?
          puts 'cloning event components'
          event.clone_event_components(clone_ind_event_id, inds.map{|x| x.core_indicator_id})
        end
      end    
    end
  end

  def down
    Event.transaction do
      e = Event.where(:event_date => '2013-10-27')
      if e.present?
        Indicator.where(:event_id => e.map{|x| x.id}).destroy_all
        e.destroy_all
      end
    end
  end
end
