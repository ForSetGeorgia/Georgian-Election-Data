class RemoveAmendmentIndicator < ActiveRecord::Migration
  def up
    # the amendment indicator that was added was incorrect due to a misunderstanding of the
    # supplemental documents
    # so the old versions need to be deleted so the correct versions can be added
    puts "getting amendment core indicators"
    core_names = ['Precincts with Amendments (%)', 'Precincts with Amendments (#)', 'Amendments (Average)', 'Amendments (#)']
    core_ids = CoreIndicatorTranslation.where(locale: 'en', name: core_names).pluck(:core_indicator_id)


    if core_ids.present?
      CoreIndicator.transaction do
        puts "deleting event indicators and data"
        indicator_ids = Indicator.where(:core_indicator_id => core_ids).pluck(:id)
        Datum.where(indicator_id: indicator_ids).delete_all
        IndicatorScale.where(indicator_id: indicator_ids).destroy_all
        Indicator.where(id: indicator_ids).delete_all

        puts "deleting event indicator relationships"
        EventIndicatorRelationship.where(:core_indicator_id => core_ids).destroy_all

        puts "deleting core indicators that are just for this event"
        CoreIndicatorTranslation.where(core_indicator_id: core_ids).delete_all
        CoreIndicator.where(id: core_ids).delete_all
      end
    end
  end

  def down
    puts 'do nothing'
  end
end
