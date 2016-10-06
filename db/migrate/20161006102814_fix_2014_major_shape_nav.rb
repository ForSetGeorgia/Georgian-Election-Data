class Fix2014MajorShapeNav < ActiveRecord::Migration
  def up
    # when 2014 major was created, 2012 party list was used for the clone
    # - this event did not have majoritarian districts and so the shape nav was not properly created
    CustomShapeNavigation.transaction do
      event_2010 = Event.includes(:event_translations).where(event_translations: {name: '2010 Local Election - Majoritarian'}).first
      event_2014 = Event.includes(:event_translations).where(event_translations: {name: '2014 Local Election - Majoritarian'}).first

      if event_2010.present? && event_2014.present?
        # delete the bad nav
        puts "- deleting bad nav"
        CustomShapeNavigation.where(event_id: event_2014.id).destroy_all


        # create the new nav
        event_2010.custom_shape_navigations.each do |nav|
          puts "- creating new nav for shape type #{nav.shape_type_id}"
          nav.clone_for_event(event_2014.id)
        end
      else
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!1"
        puts "- could not find the 2010 or 2014 major election"
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!1"
      end
    end

    JsonCache.clear_shape_files

  end

  def down
    puts "do nothing"

    JsonCache.clear_shape_files
  end
end
