class Fix2016Indicators < ActiveRecord::Migration
  def up

    ################################################
    # the list of indicators are not acurate, so load the csv file to fix it all
    # csv file was downloaded from the admin section after the above was completed
    # and updated to fix the errors
    ################################################
    locale = I18n.locale
    puts "locale was #{locale}, now en"
    I18n.locale = :en

    vl = Event.includes(:event_translations).where(:event_date => '2016-09-01', event_translations: {name: '2016 September Voters List'}).first
    prop = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Majoritarian'}).first
    init_group = CoreIndicator.includes(:core_indicator_translations).where(core_indicator_translations: {name: 'Initiative Group'}).first
    clone_core_ind_id = 59 #unm

    ids = [vl.id, prop.id, major.id]
    puts "election ids = #{ids}"

    # first quickly delete all indicators and data for these elections
    puts "deleting event indicators and data"
    indicator_ids = Indicator.where(:event_id => ids).pluck(:id)
    Datum.where(indicator_id: indicator_ids).delete_all
    DataSet.where(:event_id => ids).delete_all
    scale_ids = IndicatorScale.where(indicator_id: indicator_ids).pluck(:id)
    IndicatorScaleTranslation.where(indicator_scale_id: scale_ids).delete_all
    IndicatorScale.where(id: scale_ids).delete_all
    Indicator.where(id: indicator_ids).delete_all


    # now load the new indicators
    puts "---------------"
    puts "- voters list 2016 - loading indicators from csv file"
    file_path = "#{Rails.root}/db/load data/2016/fix_Indicator_Names_Scales_for_2016_September_Voters_List.csv"
    Indicator.build_from_csv(File.new(file_path))

    puts "---------------"
    puts "- prop 2016 - loading indicators from csv file"
    file_path = "#{Rails.root}/db/load data/2016/fix_Indicator_Names_Scales_for_2016_Parliamentary_-_Party_List.csv"
    Indicator.build_from_csv(File.new(file_path))

    puts "---------------"
    puts "- major list 2016 - loading indicators from csv file"
    file_path = "#{Rails.root}/db/load data/2016/fix_Indicator_Names_Scales_for_2016_Parliamentary_-_Majoritarian.csv"
    Indicator.build_from_csv(File.new(file_path))

    puts "---------------"
    puts "- major list 2016 - add event indicator relationship for Initiative Group"
    EventIndicatorRelationship.clone_from_core_indicator(major.id, clone_core_ind_id, major.id, init_group.id)


    I18n.locale = locale


    I18n.available_locales.each do |locale|
      Rails.cache.delete("event_menu_json_#{locale}")
      Rails.cache.delete("live_event_menu_json_#{locale}")
      JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
      JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
    end


  end

  def down
    puts "do nothing"
  end
end
