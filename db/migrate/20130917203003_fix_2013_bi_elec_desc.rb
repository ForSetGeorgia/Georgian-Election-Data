# encoding: UTF-8
class Fix2013BiElecDesc < ActiveRecord::Migration
  def up
    EventTranslation.transaction do
      event_name = '2013 Parliamentary Bi-election - Majoritarian'
      event = EventTranslation.where(:name => event_name)
      if event.present?
        event.first.description = 'The results of the April 27, 2013 elections in Bagdati district 52, Nadzaladevi district 9 and Samtredia district 54 for vacant majoritarian seats in Parliament.'
        event.first.save
      end
    
      event_name = '2013 წლის შუალედური საპარლამენტო არჩევნები - მაჟორიტარული'
      event = EventTranslation.where(:name => event_name)
      if event.present?
        event.first.description = '2013 წლის 27 აპრილის არჩევნების შედეგები ბაღდათის 52-ე, ნაძალადევის მე-9 და სამტრედიის 54-ე ოლქებში პარლამენტის ვაკანტური მაჟორიტარული ადგილებისთვის.'
        event.first.save
      end
    end
  end

  def down
    # do nothing
  end
end
