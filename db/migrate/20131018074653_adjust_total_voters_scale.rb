class AdjustTotalVotersScale < ActiveRecord::Migration
  require 'json_cache'
  def up
    name = 'Total Voters'
    shape_type_ids = [3,7]
    trans = CoreIndicatorTranslation.where(:locale => 'en', :name => name)
    scales = ['0-10000', '10000-20000', '20000-30000', '30000-40000', '40000-50000', '50000-75000', '75000-100000', '100000-125000', '125000-150000', '>150000']
    
    if trans.present?
      core_id = trans.first.core_indicator_id
      
      IndicatorScale.transaction do
        indicators = Indicator.select('id').where(:core_indicator_id => core_id, :shape_type_id => shape_type_ids)
        if indicators.present?
          indicators.map{|x| x.id}.each do |indicator_id|
            puts "ind id = #{indicator_id}"

            # delete the old scales
            IndicatorScale.where(:indicator_id => indicator_id).destroy_all
            
            # add the new scales
            scales.each do |scale_item|
              scale = IndicatorScale.create(:indicator_id => indicator_id)
              I18n.available_locales.each do |locale|
                scale.indicator_scale_translations.create(:locale => locale.to_s, :name => scale_item)
              end
            end
          end
      
          # clear cache for each event that has this ind
          inds = Indicator.select('distinct event_id').where(:id => indicators.map{|x| x.id})
          if inds.present?
            inds.map{|x| x.event_id}.each do |event_id|
              JsonCache.clear_all_data(event_id)
            end
          end
        end      
      end
    end
  end

  def down
    name = 'Total Voters'
    shape_type_ids = [3,7]
    trans = CoreIndicatorTranslation.where(:locale => 'en', :name => name)
    scales = ['0', '0-5000', '5000-10000', '10000-15000', '15000-20000', '20000-25000', '>25000']
    
    if trans.present?
      core_id = trans.first.core_indicator_id
      
      IndicatorScale.transaction do
        indicators = Indicator.select('id').where(:core_indicator_id => core_id, :shape_type_id => shape_type_ids)
        if indicators.present?
          indicators.map{|x| x.id}.each do |indicator_id|
            # delete the old scales
            IndicatorScale.where(:indicator_id => indicator_id).destroy_all
            
            # add the new scales
            scales.each do |scale_item|
              scale = IndicatorScale.create(:indicator_id => indicator_id)
              I18n.available_locales.each do |locale|
                scale.indicator_scale_translations.create(:locale => locale.to_s, :name => scale_item)
              end
            end
          end
      
          # clear cache for each event that has this ind
          inds = Indicator.select('distinct event_id').where(:id => indicators.map{|x| x.id})
          if inds.present?
            inds.map{|x| x.event_id}.each do |event_id|
              JsonCache.clear_all_data(event_id)
            end
          end
        end      
      end
    end
  end
end
