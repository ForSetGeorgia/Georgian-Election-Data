# encoding: UTF-8
class AddMissingBallotsInds < ActiveRecord::Migration
  def up
    total_ind_id = 15
    event_names = ['2012 Parliamentary - Party List', '2012 Parliamentary - Majoritarian']
    events = Event.includes(:event_translations).where(:event_translations => {:name => event_names, :locale => 'en'})

    old_core_names = ['Precincts with Validation Errors (%)', 'Precincts with Validation Errors (#)', 'Average Number of Validation Errors', 'Number of Validation Errors']
    cores = []
    old_core_names.each do |old_name|
      x = CoreIndicator.includes(:core_indicator_translations).where(:core_indicator_translations => {:name => old_name, :locale => 'en'})
      cores << x.first if x.present?
    end

    if events.present? && events.length == event_names.length
      CoreIndicator.transaction do
        ##########################
        # add core inds
        # precincts with More Ballots Than Votes (%)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with More Ballots Than Votes (%)')
        if exists.present?
          prec_missing_perc = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_perc = CoreIndicator.create(:indicator_type_id => 1, :number_format => '%')
          prec_missing_perc.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with More Ballots Than Votes (%)',
            :name_abbrv => 'More Ballots Than Votes (%)', :description => 'Precincts with More Ballots Than Votes (%)')
          prec_missing_perc.core_indicator_translations.create(:locale => 'ka', :name => 'Precincts with More Ballots Than Votes (%)',
            :name_abbrv => 'More Ballots Than Votes (%)', :description => 'Precincts with More Ballots Than Votes (%)')
        end
        
        # precincts with More Ballots Than Votes (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with More Ballots Than Votes (#)')
        if exists.present?
          prec_missing_num = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_num = CoreIndicator.create(:indicator_type_id => 1)
          prec_missing_num.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with More Ballots Than Votes (#)',
            :name_abbrv => 'More Ballots Than Votes (#)', :description => 'Precincts with More Ballots Than Votes (#)')
          prec_missing_num.core_indicator_translations.create(:locale => 'ka', :name => 'Precincts with More Ballots Than Votes (#)',
            :name_abbrv => 'More Ballots Than Votes (#)', :description => 'Precincts with More Ballots Than Votes (#)')
        end
        
        # avg # of More Ballots Than Votes
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Average Number of More Ballots Than Votes')
        if exists.present?
          avg = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          avg = CoreIndicator.create(:indicator_type_id => 1)
          avg.core_indicator_translations.create(:locale => 'en', :name => 'Average Number of More Ballots Than Votes',
            :name_abbrv => 'Avg Num More Ballots Than Votes', :description => 'Average Number of More Ballots Than Votes')
          avg.core_indicator_translations.create(:locale => 'ka', :name => 'Average Number of More Ballots Than Votes',
            :name_abbrv => 'Avg Num More Ballots Than Votes', :description => 'Average Number of More Ballots Than Votes')
        end

        # More Ballots Than Votes (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Number of More Ballots Than Votes')
        if exists.present?
          missing = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          missing = CoreIndicator.create(:indicator_type_id => 1)
          missing.core_indicator_translations.create(:locale => 'en', :name => 'Number of More Ballots Than Votes',
            :name_abbrv => 'More Ballots Than Votes (#)', :description => 'Number of More Ballots Than Votes')
          missing.core_indicator_translations.create(:locale => 'ka', :name => 'Number of More Ballots Than Votes',
            :name_abbrv => 'More Ballots Than Votes (#)', :description => 'Number of More Ballots Than Votes')
        end
        
        
        events.each do |event|
          # add if not exists
          if EventIndicatorRelationship.where(:event_id => event.id, :core_indicator_id => prec_missing_perc.id).blank? &&
              EventIndicatorRelationship.where(:event_id => event.id, :core_indicator_id => missing.id).blank?
            ##########################
            # create relationships
            # - non-precinct relationship
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => prec_missing_num.id,
              :sort_order => 1, :visible => true, :has_openlayers_rule_value => false)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => prec_missing_perc.id,
              :sort_order => 2, :visible => true, :has_openlayers_rule_value => true)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => avg.id,
              :sort_order => 3, :visible => true, :has_openlayers_rule_value => false)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => total_ind_id,
              :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
            # - precinct relationship
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => missing.id, :related_core_indicator_id => missing.id,
              :sort_order => 1, :visible => true, :has_openlayers_rule_value => true)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => missing.id, :related_core_indicator_id => total_ind_id,
              :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
          end


          # for each event, clone indicators/scales for new indicators
          puts "=================="
          if cores.present? && cores.length == old_core_names.length
            puts "cloning indicators for event #{event.id}"
            cores.each_with_index do |core, i|
              puts "- cloning core #{core.id}"
              new_core_id = nil
              case i
              when 0
                new_core_id = prec_missing_perc.id
              when 1
                new_core_id = prec_missing_num.id
              when 2
                new_core_id = avg.id
              when 3
                new_core_id = missing.id
              end
              
              puts "- new core id = #{new_core_id}; cloning"
              
              Indicator.clone_from_core_indicator(event.id, core.id, event.id, new_core_id) if new_core_id.present?

              puts "- finished cloning"
          
            end
          end

        end
        
        
        
        
        ##########################
        ##########################
        ##########################
        ##########################
        # add core inds
        # precincts with More Votes Than Ballots (%)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with More Votes Than Ballots (%)')
        if exists.present?
          prec_missing_perc = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_perc = CoreIndicator.create(:indicator_type_id => 1, :number_format => '%')
          prec_missing_perc.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with More Votes Than Ballots (%)',
            :name_abbrv => 'More Votes Than Ballots (%)', :description => 'Precincts with More Votes Than Ballots (%)')
          prec_missing_perc.core_indicator_translations.create(:locale => 'ka', :name => 'Precincts with More Votes Than Ballots (%)',
            :name_abbrv => 'More Votes Than Ballots (%)', :description => 'Precincts with More Votes Than Ballots (%)')
        end
        
        # precincts with More Votes Than Ballots (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with More Votes Than Ballots (#)')
        if exists.present?
          prec_missing_num = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_num = CoreIndicator.create(:indicator_type_id => 1)
          prec_missing_num.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with More Votes Than Ballots (#)',
            :name_abbrv => 'More Votes Than Ballots (#)', :description => 'Precincts with More Votes Than Ballots (#)')
          prec_missing_num.core_indicator_translations.create(:locale => 'ka', :name => 'Precincts with More Votes Than Ballots (#)',
            :name_abbrv => 'More Votes Than Ballots (#)', :description => 'Precincts with More Votes Than Ballots (#)')
        end
        
        # avg # of More Votes Than Ballots
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Average Number of More Votes Than Ballots')
        if exists.present?
          avg = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          avg = CoreIndicator.create(:indicator_type_id => 1)
          avg.core_indicator_translations.create(:locale => 'en', :name => 'Average Number of More Votes Than Ballots',
            :name_abbrv => 'Avg Num More Votes Than Ballots', :description => 'Average Number of More Votes Than Ballots')
          avg.core_indicator_translations.create(:locale => 'ka', :name => 'Average Number of More Votes Than Ballots',
            :name_abbrv => 'Avg Num More Votes Than Ballots', :description => 'Average Number of More Votes Than Ballots')
        end

        # More Votes Than Ballots (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Number of More Votes Than Ballots')
        if exists.present?
          missing = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          missing = CoreIndicator.create(:indicator_type_id => 1)
          missing.core_indicator_translations.create(:locale => 'en', :name => 'Number of More Votes Than Ballots',
            :name_abbrv => 'More Votes Than Ballots (#)', :description => 'Number of More Votes Than Ballots')
          missing.core_indicator_translations.create(:locale => 'ka', :name => 'Number of More Votes Than Ballots',
            :name_abbrv => 'More Votes Than Ballots (#)', :description => 'Number of More Votes Than Ballots')
        end
        
        
        events.each do |event|
          # add if not exists
          if EventIndicatorRelationship.where(:event_id => event.id, :core_indicator_id => prec_missing_perc.id).blank? &&
              EventIndicatorRelationship.where(:event_id => event.id, :core_indicator_id => missing.id).blank?
            ##########################
            # create relationships
            # - non-precinct relationship
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => prec_missing_num.id,
              :sort_order => 1, :visible => true, :has_openlayers_rule_value => false)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => prec_missing_perc.id,
              :sort_order => 2, :visible => true, :has_openlayers_rule_value => true)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => avg.id,
              :sort_order => 3, :visible => true, :has_openlayers_rule_value => false)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :related_core_indicator_id => total_ind_id,
              :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
            # - precinct relationship
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => missing.id, :related_core_indicator_id => missing.id,
              :sort_order => 1, :visible => true, :has_openlayers_rule_value => true)
            EventIndicatorRelationship.create(:event_id => event.id, :core_indicator_id => missing.id, :related_core_indicator_id => total_ind_id,
              :sort_order => 4, :visible => true, :has_openlayers_rule_value => false)
          end


          # for each event, clone indicators/scales for new indicators
          puts "=================="
          if cores.present? && cores.length == old_core_names.length
            puts "cloning indicators2 for event #{event.id}"
            cores.each_with_index do |core, i|
              puts "- cloning core #{core.id}"
              new_core_id = nil
              case i
              when 0
                new_core_id = prec_missing_perc.id
              when 1
                new_core_id = prec_missing_num.id
              when 2
                new_core_id = avg.id
              when 3
                new_core_id = missing.id
              end
              
              puts "- new core id = #{new_core_id}; cloning"
              
              Indicator.clone_from_core_indicator(event.id, core.id, event.id, new_core_id) if new_core_id.present?

              puts "- finished cloning"
          
            end
          end

        end
        
      end
    end
  end

  def down
    ind_names = ['Precincts with More Ballots Than Votes (%)', 'Precincts with More Ballots Than Votes (#)', 'Average Number of More Ballots Than Votes', 'Number of More Ballots Than Votes', 'Precincts with More Votes Than Ballots (%)', 'Precincts with More Votes Than Ballots (#)', 'Average Number of More Votes Than Ballots', 'Number of More Votes Than Ballots']
    inds = CoreIndicatorTranslation.where(:name => ind_names)
    if inds.present?
      CoreIndicator.transaction do
        CoreIndicator.where(:id => inds.map{|x| x.core_indicator_id}).destroy_all
      end
    end
  end
end
