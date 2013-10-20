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
          prec_missing_perc.core_indicator_translations.create(:locale => 'ka', :name => 'საარჩევნო უბნები ხმებზე მეტი ბიულეტენებით (%)',
            :name_abbrv => 'ხმებზე მეტი ბიულეტენები (%)', :description => 'საარჩევნო უბნები ხმებზე მეტი ბიულეტენებით (%)')
        end
        
        # precincts with More Ballots Than Votes (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with More Ballots Than Votes (#)')
        if exists.present?
          prec_missing_num = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_num = CoreIndicator.create(:indicator_type_id => 1)
          prec_missing_num.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with More Ballots Than Votes (#)',
            :name_abbrv => 'More Ballots Than Votes (#)', :description => 'Precincts with More Ballots Than Votes (#)')
          prec_missing_num.core_indicator_translations.create(:locale => 'ka', :name => 'საარჩევნო უბნები ხმებზე მეტი ბიულეტენებით (#)',
            :name_abbrv => 'ხმებზე მეტი ბიულეტენები (#)', :description => 'საარჩევნო უბნები ხმებზე მეტი ბიულეტენებით (#)')
        end
        
        # avg # of More Ballots Than Votes
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'More Ballots Than Votes (Average)')
        if exists.present?
          avg = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          avg = CoreIndicator.create(:indicator_type_id => 1)
          avg.core_indicator_translations.create(:locale => 'en', :name => 'More Ballots Than Votes (Average)',
            :name_abbrv => 'More Ballots Than Votes (Avg)', :description => 'More Ballots Than Votes (Average)')
          avg.core_indicator_translations.create(:locale => 'ka', :name => 'ხმებზე მეტი ბიულეტენები (საშუალო)',
            :name_abbrv => 'ხმებზე მეტი ბიულეტენები (საშუალო)', :description => 'ხმებზე მეტი ბიულეტენები (საშუალო)')
        end

        # More Ballots Than Votes (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'More Ballots Than Votes (#)')
        if exists.present?
          missing = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          missing = CoreIndicator.create(:indicator_type_id => 1)
          missing.core_indicator_translations.create(:locale => 'en', :name => 'More Ballots Than Votes (#)',
            :name_abbrv => 'More Ballots Than Votes (#)', :description => 'More Ballots Than Votes (#)')
          missing.core_indicator_translations.create(:locale => 'ka', :name => 'ხმებზე მეტი ბიულეტენები (#)',
            :name_abbrv => 'ხმებზე მეტი ბიულეტენები (#)', :description => 'ხმებზე მეტი ბიულეტენები (#)')
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

              if i == 3
                puts "-- this is the last core ind, fixing stuff"
                # clone process does not work when ind has parent id that is not itself
                # - manual fix for precincts (%) -> number
                fix_inds = Indicator.where(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :shape_type_id => 3)
                if fix_inds.present?
                  puts "-- found ind for prec missing % at district"
                  Indicator.where(:event_id => event.id, :core_indicator_id => new_core_id).each do |fix_ind|
                    puts "--- fixing parent id from #{fix_ind.parent_id} to #{fix_inds.first.id}"
                    fix_ind.parent_id = fix_inds.first.id
                    fix_ind.save

                    # the old validation errors scale for number of validation errors (at precinct level)
                    # had scale of < 0
                    # this was cloned for the new indicators, but is no longer needed
                    fix_scale_ids = fix_ind.indicator_scales.map{|x| x.id}
                    if fix_scale_ids.present?
                      puts "--- removing '<0' scale"
                      matches = IndicatorScaleTranslation.select('indicator_scale_id').where(:indicator_scale_id => fix_scale_ids, :name => '<0')
                      IndicatorScale.where(:id => matches.map{|x| x.indicator_scale_id}.uniq).destroy_all if matches.present?
                    end                   

                  end
                end
              end

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
          prec_missing_perc.core_indicator_translations.create(:locale => 'ka', :name => 'საარჩევნო უბნები ბიულეტენებზე მეტი ხმების რაოდენობით (%)',
            :name_abbrv => 'ბიულეტენებზე მეტი ხმები (%)', :description => 'საარჩევნო უბნები ბიულეტენებზე მეტი ხმების რაოდენობით (%)')
        end
        
        # precincts with More Votes Than Ballots (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Precincts with More Votes Than Ballots (#)')
        if exists.present?
          prec_missing_num = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          prec_missing_num = CoreIndicator.create(:indicator_type_id => 1)
          prec_missing_num.core_indicator_translations.create(:locale => 'en', :name => 'Precincts with More Votes Than Ballots (#)',
            :name_abbrv => 'More Votes Than Ballots (#)', :description => 'Precincts with More Votes Than Ballots (#)')
          prec_missing_num.core_indicator_translations.create(:locale => 'ka', :name => 'საარჩევნო უბნები ბიულეტენებზე მეტი ხმების რაოდენობით (#)',
            :name_abbrv => 'ბიულეტენებზე მეტი ხმები (#)', :description => 'საარჩევნო უბნები ბიულეტენებზე მეტი ხმების რაოდენობით (#)')
        end
        
        # avg # of More Votes Than Ballots
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'More Votes Than Ballots (Average)')
        if exists.present?
          avg = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          avg = CoreIndicator.create(:indicator_type_id => 1)
          avg.core_indicator_translations.create(:locale => 'en', :name => 'More Votes Than Ballots (Average)',
            :name_abbrv => 'More Votes Than Ballots (Avg)', :description => 'More Votes Than Ballots (Average)')
          avg.core_indicator_translations.create(:locale => 'ka', :name => 'ბიულეტენებზე მეტი ხმები (საშუალო)',
            :name_abbrv => 'ბიულეტენებზე მეტი ხმები (საშუალო)', :description => 'ბიულეტენებზე მეტი ხმები (საშუალო)')
        end

        # More Votes Than Ballots (#)
        exists = CoreIndicatorTranslation.where(:locale => 'en', :name => 'More Votes Than Ballots (#)')
        if exists.present?
          missing = CoreIndicator.find_by_id(exists.first.core_indicator_id)
        else
          missing = CoreIndicator.create(:indicator_type_id => 1)
          missing.core_indicator_translations.create(:locale => 'en', :name => 'More Votes Than Ballots (#)',
            :name_abbrv => 'More Votes Than Ballots (#)', :description => 'More Votes Than Ballots (#)')
          missing.core_indicator_translations.create(:locale => 'ka', :name => 'ბიულეტენებზე მეტი ხმები (#)',
            :name_abbrv => 'ბიულეტენებზე მეტი ხმები (#)', :description => 'ბიულეტენებზე მეტი ხმები (#)')
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

              if i == 3
                puts "-- this is the last core ind, fixing stuff"
                # clone process does not work when ind has parent id that is not itself
                # - manual fix for precincts (%) -> number
                fix_inds = Indicator.where(:event_id => event.id, :core_indicator_id => prec_missing_perc.id, :shape_type_id => 3)
                if fix_inds.present?
                  puts "-- found ind for prec missing % at district"
                  Indicator.where(:event_id => event.id, :core_indicator_id => new_core_id).each do |fix_ind|
                    puts "--- fixing parent id from #{fix_ind.parent_id} to #{fix_inds.first.id}"
                    fix_ind.parent_id = fix_inds.first.id
                    fix_ind.save

                    # the old validation errors scale for number of validation errors (at precinct level)
                    # had scale of '<0'
                    # this was cloned for the new indicators, but is no longer needed
                    fix_scale_ids = fix_ind.indicator_scales.map{|x| x.id}
                    if fix_scale_ids.present?
                      puts "--- removing '<0' scale"
                      matches = IndicatorScaleTranslation.select('indicator_scale_id').where(:indicator_scale_id => fix_scale_ids, :name => '<0')
                      IndicatorScale.where(:id => matches.map{|x| x.indicator_scale_id}.uniq).destroy_all if matches.present?
                    end                   

                  end
                end
              end
              
              puts "- finished cloning"
              
            end
          end

        end
        
      end
    end
  end

  def down
    ind_names = ['Precincts with More Ballots Than Votes (%)', 'Precincts with More Ballots Than Votes (#)', 'More Ballots Than Votes (Average)', 'More Ballots Than Votes (#)', 'Average Number of More Ballots Than Votes', 'Number of More Ballots Than Votes', 'Precincts with More Votes Than Ballots (%)', 'Precincts with More Votes Than Ballots (#)', 'More Votes Than Ballots (Average)', 'More Votes Than Ballots (#)', 'Average Number of More Votes Than Ballots', 'Number of More Votes Than Ballots']
    inds = CoreIndicatorTranslation.where(:name => ind_names, :locale => 'en')
    if inds.present?
      CoreIndicator.transaction do
        CoreIndicator.where(:id => inds.map{|x| x.core_indicator_id}).destroy_all
      end
    end
  end
end
