class AddSupDocIndicators < ActiveRecord::Migration
  def up
    CoreIndicator.transaction do
      puts 'getting elections'
      prop = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Party List'}).first
      major = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Majoritarian'}).first
      rerun = Event.includes(:event_translations).where(:event_date => '2016-10-22', event_translations: {name: '2016 Parliamentary - Majoritarian Rerun'}).first
      runoff = Event.includes(:event_translations).where(:event_date => '2016-10-30', event_translations: {name: '2016 Parliamentary - Majoritarian Runoff'}).first
      event_ids = [major.id, prop.id, rerun.id, runoff.id]

      puts 'creating core ind: precinct with amend %'
      ci1 = CoreIndicator.new(indicator_type_id: 1, number_format: '%')
      ci1.core_indicator_translations.build(locale: 'en', name: 'Precincts with an Amendment (%)', name_abbrv: 'Amendment (%)', description: 'Precincts with an Amendment (%)')
      ci1.core_indicator_translations.build(locale: 'ka', name: 'უბნები შესწორებით (%)', name_abbrv: 'შესწორება (%)', description: 'უბნები შესწორებით (%)')
      ci1.save

      puts 'creating core ind: precinct with amend #'
      ci2 = CoreIndicator.new(indicator_type_id: 1)
      ci2.core_indicator_translations.build(locale: 'en', name: 'Precincts with an Amendment (#)', name_abbrv: 'Amendment (#)', description: 'Precincts with an Amendment (#)')
      ci2.core_indicator_translations.build(locale: 'ka', name: 'უბნები შესწორებით (#)', name_abbrv: 'შესწორება (#)', description: 'უბნები შესწორებით (#)')
      ci2.save

      puts 'creating core ind: has amend'
      ci3 = CoreIndicator.new(indicator_type_id: 1)
      ci3.core_indicator_translations.build(locale: 'en', name: 'Has Amendment', name_abbrv: 'Amendment', description: 'Amendment')
      ci3.core_indicator_translations.build(locale: 'ka', name: 'აქვს შესწორება', name_abbrv: 'შესწორება', description: 'შესწორება')
      ci3.save


      puts 'creating core ind: precinct with exp note %'
      ci4 = CoreIndicator.new(indicator_type_id: 1, number_format: '%')
      ci4.core_indicator_translations.build(locale: 'en', name: 'Precincts with an Explanatory Note (%)', name_abbrv: 'Explanatory Note (%)', description: 'Precincts with an Amendment (%)')
      ci4.core_indicator_translations.build(locale: 'ka', name: 'უბნები ახსნა-განმარტებითი ჩანაწერით (%)', name_abbrv: 'ახსნა-განმარტებითი ჩანაწერი (%)', description: 'უბნები ახსნა-განმარტებითი ჩანაწერით (%)')
      ci4.save

      puts 'creating core ind: precinct with exp note #'
      ci5 = CoreIndicator.new(indicator_type_id: 1)
      ci5.core_indicator_translations.build(locale: 'en', name: 'Precincts with an Explanatory Note (#)', name_abbrv: 'Explanatory Note (#)', description: 'Precincts with an Amendment (#)')
      ci5.core_indicator_translations.build(locale: 'ka', name: 'უბნები ახსნა-განმარტებითი ჩანაწერით (#)', name_abbrv: 'ახსნა-განმარტებითი ჩანაწერი (#)', description: 'უბნები ახსნა-განმარტებითი ჩანაწერით (#)')
      ci5.save

      puts 'creating core ind: has exp note'
      ci6 = CoreIndicator.new(indicator_type_id: 1)
      ci6.core_indicator_translations.build(locale: 'en', name: 'Has Explanatory Note', name_abbrv: 'Explanatory Note', description: 'Explanatory Note')
      ci6.core_indicator_translations.build(locale: 'ka', name: 'აქვს ახსნა-განმარტებითი ჩანაწერი', name_abbrv: 'ახსნა-განმარტებითი ჩანაწერი', description: 'ახსნა-განმარტებითი ჩანაწერი')
      ci6.save


      # create relationships
      # precinct with an Amendment (%)
      # - precinct with an Amendment (#)
      # - precinct with an Amendment (%) (has openlayers)
      # - total voter turnout (#)
      # Has Amendment (#)
      # - Has Amendment (has openlayers)
      # - total voter turnout (#)
      puts 'creating relationships'
      total_turnout_id = 15
      event_ids.each do |event_id|
        if EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => ci1.id).blank?
          puts '- creating non-precinct relationship'
          # - non-precinct relationship
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci1.id, :related_core_indicator_id => ci2.id,
            :sort_order => 1, :visible => true, :has_openlayers_rule_value => false)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci1.id, :related_core_indicator_id => ci1.id,
            :sort_order => 2, :visible => true, :has_openlayers_rule_value => true)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci1.id, :related_core_indicator_id => total_turnout_id,
            :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
        end

        if EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => ci3.id).blank?
          puts '- creating precinct relationship'
          # - precinct relationship
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci3.id, :related_core_indicator_id => ci3.id,
            :sort_order => 1, :visible => true, :has_openlayers_rule_value => true)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci3.id, :related_core_indicator_id => total_turnout_id,
            :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
        end
      end

      # create relationships
      # precinct with an exp note (%)
      # - precinct with an exp note (#)
      # - precinct with an exp note (%) (has openlayers)
      # - total voter turnout (#)
      # has exp note
      # - has exp note (has openlayers)
      # - total voter turnout (#)
      puts 'creating relationships'
      total_turnout_id = 15
      event_ids.each do |event_id|
        if EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => ci4.id).blank?
          puts '- creating non-precinct relationship'
          # - non-precinct relationship
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci4.id, :related_core_indicator_id => ci5.id,
            :sort_order => 1, :visible => true, :has_openlayers_rule_value => false)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci4.id, :related_core_indicator_id => ci4.id,
            :sort_order => 2, :visible => true, :has_openlayers_rule_value => true)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci4.id, :related_core_indicator_id => total_turnout_id,
            :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
        end

        if EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => ci6.id).blank?
          puts '- creating precinct relationship'
          # - precinct relationship
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci6.id, :related_core_indicator_id => ci6.id,
            :sort_order => 1, :visible => true, :has_openlayers_rule_value => true)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci6.id, :related_core_indicator_id => total_turnout_id,
            :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
        end
      end


      orig_locale = I18n.locale
      I18n.locale = :en
      puts 'loading indicators/scales'
      Indicator.build_from_csv(File.open("#{Rails.root}/db/load data/2016/add_sup_doc_indicator_scale-pary_list.csv"))
      Indicator.build_from_csv(File.open("#{Rails.root}/db/load data/2016/add_sup_doc_indicator_scales-major.csv"))
      Indicator.build_from_csv(File.open("#{Rails.root}/db/load data/2016/add_sup_doc_indicator_scales-major_rerun.csv"))
      Indicator.build_from_csv(File.open("#{Rails.root}/db/load data/2016/add_sup_doc_indicator_scales-major_runoff.csv"))

      I18n.locale = orig_locale

    end

  end

  def down
    puts "getting 2016 electons"
    prop = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Majoritarian'}).first
    rerun = Event.includes(:event_translations).where(:event_date => '2016-10-22', event_translations: {name: '2016 Parliamentary - Majoritarian Rerun'}).first
    runoff = Event.includes(:event_translations).where(:event_date => '2016-10-30', event_translations: {name: '2016 Parliamentary - Majoritarian Runoff'}).first
    event_ids = [major.id, prop.id, rerun.id, runoff.id]

    puts "getting amendment core indicators"
    core_names = [
      'Precincts with an Amendment (%)', 'Precincts with an Amendment (#)', 'Has Amendment',
      'Precincts with an Explanatory Note (%)', 'Precincts with an Explanatory Note (#)', 'Has Explanatory Note'
    ]
    core_ids = CoreIndicatorTranslation.where(locale: 'en', name: core_names).pluck(:core_indicator_id)


    if event_ids.present? && core_ids.present?
      CoreIndicator.transaction do
        puts "deleting event indicators and data"
        indicator_ids = Indicator.where(:event_id => event_ids, :core_indicator_id => core_ids).pluck(:id)
        Datum.where(indicator_id: indicator_ids).delete_all
        IndicatorScale.where(indicator_id: indicator_ids).destroy_all
        Indicator.where(id: indicator_ids).delete_all

        puts "deleting event indicator relationships"
        EventIndicatorRelationship.where(:event_id => event_ids, :core_indicator_id => core_ids).destroy_all

        puts "deleting core indicators that are just for this event"
        CoreIndicatorTranslation.where(core_indicator_id: core_ids).delete_all
        CoreIndicator.where(id: core_ids).delete_all
      end
    end

  end
end
