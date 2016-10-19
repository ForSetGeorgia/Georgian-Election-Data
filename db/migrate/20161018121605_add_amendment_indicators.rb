class AddAmendmentIndicators < ActiveRecord::Migration
  def up
    CoreIndicator.transaction do
      puts 'getting elections'
      prop = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Party List'}).first
      major = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Majoritarian'}).first
      event_ids = [major.id, prop.id]

      puts 'creating core ind: precinct with amend %'
      ci1 = CoreIndicator.new(indicator_type_id: 1, number_format: '%')
      ci1.core_indicator_translations.build(locale: 'en', name: 'Precincts with Amendments (%)', name_abbrv: 'Amendments (%)', description: 'Precincts with Amendments (%)')
      ci1.core_indicator_translations.build(locale: 'ka', name: 'ოქმები შესწორებებით (%)', name_abbrv: 'შესწორებებით (%)', description: 'ოქმები შესწორებებით (%)')
      ci1.save

      puts 'creating core ind: precinct with amend #'
      ci2 = CoreIndicator.new(indicator_type_id: 1)
      ci2.core_indicator_translations.build(locale: 'en', name: 'Precincts with Amendments (#)', name_abbrv: 'Amendments (#)', description: 'Precincts with Amendments (#)')
      ci2.core_indicator_translations.build(locale: 'ka', name: 'ოქმები შესწორებებით (#)', name_abbrv: 'შესწორებებით (#)', description: 'ოქმები შესწორებებით (#)')
      ci2.save

      puts 'creating core ind: amend (avg)'
      ci3 = CoreIndicator.new(indicator_type_id: 1)
      ci3.core_indicator_translations.build(locale: 'en', name: 'Amendments (Average)', name_abbrv: 'Amendments (Average)', description: 'Amendments (Average)')
      ci3.core_indicator_translations.build(locale: 'ka', name: 'შესწორებები (საშუალოდ) ', name_abbrv: 'შესწორებები (საშუალოდ) ', description: 'შესწორებები (საშუალოდ) ')
      ci3.save

      puts 'creating core ind: amend (#)'
      ci4 = CoreIndicator.new(indicator_type_id: 1)
      ci4.core_indicator_translations.build(locale: 'en', name: 'Amendments (#)', name_abbrv: 'Amendments (#)', description: 'Amendments (#)')
      ci4.core_indicator_translations.build(locale: 'ka', name: 'შესწორებები (#)', name_abbrv: 'შესწორებები (#)', description: 'შესწორებები (#)')
      ci4.save


      # create relationships
      # precinct with amendments (%)
      # - precinct with amendments (#)
      # - precinct with amendments (%) (has openlayers)
      # - amendments (avg)
      # - total voter turnout (#)
      # amendments (#)
      # - amendments (#) (has openlayers)
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
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci1.id, :related_core_indicator_id => ci3.id,
            :sort_order => 3, :visible => true, :has_openlayers_rule_value => false)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci1.id, :related_core_indicator_id => total_turnout_id,
            :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
        end

        if EventIndicatorRelationship.where(:event_id => event_id, :core_indicator_id => ci4.id).blank?
          puts '- creating precinct relationship'
          # - precinct relationship
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci4.id, :related_core_indicator_id => ci4.id,
            :sort_order => 1, :visible => true, :has_openlayers_rule_value => true)
          EventIndicatorRelationship.create(:event_id => event_id, :core_indicator_id => ci4.id, :related_core_indicator_id => total_turnout_id,
            :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
        end
      end

      orig_locale = I18n.locale
      I18n.locale = :en
      puts 'loading indicators/scales'
      Indicator.build_from_csv(File.open("#{Rails.root}/db/load data/2016/add_amendment_indicator_scale-pary_list.csv"))
      Indicator.build_from_csv(File.open("#{Rails.root}/db/load data/2016/add_amendment_indicator_scales-major.csv"))

      I18n.locale = orig_locale

    end

  end

  def down
    puts "getting 2016 electons"
    prop = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Party List'}).first
    major = Event.includes(:event_translations).where(:event_date => '2016-10-08', event_translations: {name: '2016 Parliamentary - Majoritarian'}).first
    event_ids = [major.id, prop.id]

    puts "getting amendment core indicators"
    core_names = ['Precincts with Amendments (%)', 'Precincts with Amendments (#)', 'Amendments (Average)', 'Amendments (#)']
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
