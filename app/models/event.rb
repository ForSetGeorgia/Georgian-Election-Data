class Event < ActiveRecord::Base
  translates :name, :name_abbrv, :description

  has_many :event_translations, :dependent => :destroy
  has_many :indicators
	has_many :menu_live_events, :dependent => :destroy
  belongs_to :shape
  belongs_to :event_type
  has_many :event_indicator_relationships, :dependent => :destroy
	has_many :event_custom_views, :dependent => :destroy
	has_many :data_sets, :dependent => :destroy
  has_many :custom_shape_navigations, :dependent => :destroy
  accepts_nested_attributes_for :event_translations
  attr_accessible :shape_id, :event_type_id, :event_date, :is_default_view,
		:event_translations_attributes, :has_official_data, :has_live_data, :default_core_indicator_id

  validates :event_type_id, :event_date, :presence => true
  validates_inclusion_of :default_core_indicator_id, :in => CoreIndicator.ids, :if => :default_core_indicator_id_present?
  #do not require shape id for the geo data might not be loaded yet
#  validates :shape_id, :presence => true

  def default_core_indicator_id_present?
    self.default_core_indicator_id.present?
  end

  def is_voter_list?
    x = false
    type = EventType.select('is_voters_list').find(self.event_type_id)
    x = type.present? && type.is_voters_list
    return x
  end



	# get all events that have live menu records
	def self.live_events_menu(order = "asc")
		with_translations(I18n.locale)
		.joins(:menu_live_events)
		.order("menu_live_events.menu_start_date #{order}, event_date, event_translations.name")
	end

	# get all events that have live accounts and are currently active
	def self.active_live_events_menu(order = "asc")
		with_translations(I18n.locale)
		.includes(:menu_live_events)
		.where("curdate() between menu_live_events.menu_start_date and menu_live_events.menu_end_date")
		.order("menu_live_events.menu_start_date #{order}, event_date, event_translations.name")
#		.where("events.has_live_data = 1 and curdate() between menu_live_events.menu_start_date and menu_live_events.menu_end_date")
	end


  def self.get_public_events_by_type(event_type_id)
    if event_type_id
			Rails.cache.fetch("events_by_type_#{event_type_id}_#{I18n.locale}") {
				x = Event.with_translations(I18n.locale)
				.where("event_type_id = ? and shape_id is not null and (has_official_data = 1 || has_live_data = 1)", event_type_id)
				.order("event_date DESC, event_translations.name ASC")
				# do this to force a call to the db to get the data
				# so the data will actually be cached
				x.collect{|x| x}
			}
    end
  end

	# get all events that have datasets
	def self.data_sets(order = "asc")
		with_translations(I18n.locale)
		.joins(:data_sets)
		.order("data_sets.timestamp #{order}, event_translations.name")
	end

  def self.get_events_by_type(event_type_id)
    if event_type_id.nil?
      return nil
    else
			Rails.cache.fetch("events_by_type_#{event_type_id}_#{I18n.locale}") {
				x = Event.with_translations(I18n.locale)
				.where("event_type_id = ? and shape_id is not null and (has_official_data = 1 or has_live_data = 1)", event_type_id)
				.order("event_date DESC, event_translations.name ASC")
				# do this to force a call to the db to get the data
				# so the data will actually be cached
				x.collect{|x| x}
			}
    end
  end

  def self.get_all_events(locale = I18n.locale)
		with_translations(locale).includes(:event_type)
		.order("event_types.sort_order asc, event_date DESC, event_translations.name ASC")
  end

  def self.get_all_events_by_date(locale = I18n.locale)
		with_translations(locale)
		.order("event_date DESC, event_translations.name ASC")
  end

  def self.get_all_election_events_by_date(locale = I18n.locale)
		with_translations(locale)
		.where("event_type_id in (1,3,4,5)")
		.order("event_date DESC, event_translations.name ASC")
  end

	def self.get_events_with_summary_indicators
		select("distinct events.id, events.shape_id, core_indicators.indicator_type_id, events.has_official_data, events.has_live_data")
		.joins(:indicators => {:core_indicator => :indicator_type})
		.where(:indicator_types => {:has_summary => true})
		.order("events.id")
	end


  # get events that are elections and public
  def self.public_official_elections(limit = 3, ids = nil)
		x = with_translations(I18n.locale)
    .where(:has_official_data => true, :event_type_id => EventType.ids_with_elections)
		.order("event_date DESC, event_translations.name ASC")
		.limit(limit)

		if ids.present?
		  x = x.where(:id => ids)
		end

	  return x
  end

  # get events that are voters lists and public
  def self.public_official_voters_lists(limit = 3)
		with_translations(I18n.locale)
    .where(:has_official_data => true, :event_type_id => EventType.ids_with_voters_lists)
    .where('shape_id is not null')
		.order("event_date DESC, event_translations.name ASC")
		.limit(limit)
  end

  # get the number of each event type that is public and
  # how many data items are in each event type
  ###########################
  ###### NOTE: values are hardcoded into this method
  ###########################
  def self.election_type_stats()
		Rails.cache.fetch("election_type_stats") {
      data = Hash.new

      sql = "select x.event_type_id, x.id, x.data_set_id "
      sql << "from (select e.event_type_id, e.id, ds.id as data_set_id, ds.data_type, ds.timestamp "
      sql << "from events as e inner join data_sets as ds on ds.event_id = e.id "
      sql << "where ds.show_to_public = 1 "
      sql << "order by e.event_type_id, e.id, ds.timestamp desc, ds.id desc) as x "
      sql << "group by event_type_id, id"

      x = find_by_sql(sql)

      if x.present?
        election_types = EventType.ids_with_elections
        election_ind_id = 15
        voter_list_types = EventType.ids_with_voters_lists
        voter_list_ind_id = 17
        shape_type_ids = ShapeType.precint_ids

        # get election stats
        ids = x.select{|x| election_types.index(x.event_type_id).present?}.map{|x| x[:data_set_id]}
        total_data = Datum.joins(:indicator)
              .where(:indicators => {:core_indicator_id => election_ind_id, :shape_type_id => shape_type_ids}, :data => {:data_set_id => ids})
              .sum(:value)
        hash = Hash.new
        hash['total'] = ids.length
        hash['total_data'] = ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(total_data, :precision => 0))
        data['elections'] = hash

        # get voter list stats
        ids = x.select{|x| voter_list_types.index(x.event_type_id).present?}.map{|x| x[:data_set_id]}
        total_data = Datum.joins(:indicator)
              .where(:indicators => {:core_indicator_id => voter_list_ind_id, :shape_type_id => shape_type_ids}, :data => {:data_set_id => ids})
              .sum(:value)
        hash = Hash.new
        hash['total'] = ids.length
        hash['total_data'] = ActionController::Base.helpers.number_with_delimiter(ActionController::Base.helpers.number_with_precision(total_data, :precision => 0))
        data['voters_list'] = hash
      end

      data
    }
  end

  # clone the event and its translations
  def self.clone_from_event(event_id, event_date)
    event = nil
    if event_id.present? && event_date.present?
      e = Event.find_by_id(event_id)
      if e.present?
        event = Event.new(:shape_id => e.shape_id, :event_type_id => e.event_type_id,
          :event_date => event_date, :is_default_view => false,
    		  :has_official_data => false, :has_live_data => false)
        e.event_translations.each do |trans|
          event.event_translations.build(:locale => trans.locale, :name => trans.name,
              :name_abbrv => trans.name_abbrv, :description => trans.description)
        end
        event.save
      end
    end
    return event
  end


  # copy everything from an existing event into a new event
  # - if core indicator ids passed in, only copy those indicators
  # copy: indicators, relationships, custom event views, custom shape navigation
  def clone_event_components(event_id, options={})
    core_indicator_ids = options[:core_indicator_ids]
    clone_indicators = options[:clone_indicators].nil? ? true : options[:clone_indicators]

    if event_id.present?
      Event.transaction do

        if clone_indicators
          found_ind_ids = []
          # create indicators and the scales
          # - indicator.clone_for_event will automatically get any children inds, so only need to get parents
          indicators = Indicator.includes(:indicator_scales => :indicator_scale_translations)
            .where(:indicators => {:event_id => event_id, :ancestry => nil})
          if core_indicator_ids.present?
            indicators = indicators.where(:indicators => {:core_indicator_id => core_indicator_ids})
          end
          if indicators.present?
            puts "-> cloning #{indicators.length} indicators"
            indicators.each do |ind|
              found_ind_ids << ind.core_indicator_id
              ind.clone_for_event(self.id)
            end
          end

          puts "@@@@@@@@@@@@@@@@@@"
          puts "found ids = #{found_ind_ids.uniq.sort}"
          puts "exist ids = #{core_indicator_ids.sort}"
          puts "@@@@@@@@@@@@@@@@@@"

          # if found_ind_ids length != core_indicator_ids length
          # - then the core ind was not in the event and has to be pulled from another election
          if core_indicator_ids.present? && core_indicator_ids.length > found_ind_ids.uniq.length
            missing_ids = core_indicator_ids - found_ind_ids.uniq
            puts "----------"
            puts "--> #{missing_ids.length} core indicators do not exist for the provided event, looking for indicators to clone from another event"

            missing_ids.each do |missing_id|
              puts "---> looking for core ind #{missing_id}"
              possible_match = Indicator.select('event_id, max(created_at) as created_at')
                                        .where(core_indicator_id: missing_id)
                                        .group(:event_id).order('created_at desc').first
              if possible_match.present?
                puts "----> looking for match in event #{possible_match.event_id}"
                indicators = Indicator.includes(:indicator_scales => :indicator_scale_translations)
                  .where(:indicators => {:event_id => possible_match.event_id, :ancestry => nil, :core_indicator_id => missing_id})
                if indicators.present?
                  puts "---> cloning #{indicators.length} indicators"
                  indicators.each do |ind|
                    ind.clone_for_event(self.id)
                  end
                end
              else
                puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                puts "---> WARNING - the indicator could not be found in another event to clone indicators"
                puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
              end
            end
            puts "----------"
          end
        end

        puts "----------"
        # create relationships
        found_ind_ids = []
        relationships = EventIndicatorRelationship.where(:event_id => event_id)
        if core_indicator_ids.present?
          relationships = relationships.where(["core_indicator_id in (?) or indicator_type_id is not null", core_indicator_ids])
        end
        if relationships.present?
          puts "-> cloning #{relationships.length} relationships"
          relationships.each_with_index do |rel, reli|
            found_ind_ids << rel.core_indicator_id
            rel.clone_for_event(self.id)
          end
        end

        # if found_ind_ids length != core_indicator_ids length
        # - then the core ind was not in the event and has to be pulled from another election
        if core_indicator_ids.present? && core_indicator_ids.length > found_ind_ids.uniq.length
          missing_ids = core_indicator_ids - found_ind_ids
          puts "----------"
          puts "--> #{missing_ids.length} core indicator relationships do not exist for the provided event, looking for relationships to clone from another event"

          missing_ids.each do |missing_id|
            puts "---> looking for core ind #{missing_id}"
            possible_match = EventIndicatorRelationship.select('event_id, max(created_at) as created_at')
                                      .where(core_indicator_id: missing_id, indicator_type_id: nil)
                                      .group(:event_id).order('created_at desc').first
            if possible_match.present?
              puts "----> looking for match in event #{possible_match.event_id}"
              relationships = EventIndicatorRelationship.where(["event_id = ? and core_indicator_id = ? and indicator_type_id is null", possible_match.event_id, missing_id])
              if relationships.present?
                puts "---> cloning #{relationships.length} relationships"
                relationships.each do |rel|
                  rel.clone_for_event(self.id)
                end
              end
            else
              puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
              puts "---> WARNING - the indicator could not be found in another event to clone relationships; could be that this core ind does not have it's own relationship"
              puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            end
          end
        end



        # create custom views
        views = EventCustomView.includes(:event_custom_view_translations).where(:event_id => event_id)
        if views.present?
          puts "---> cloning #{views.length} views"
          views.each do |view|
            view.clone_for_event(self.id)
          end
        end

        # create custom shape navigation
        navs = CustomShapeNavigation.includes(:custom_shape_navigation_translations).where(:event_id => event_id)
        if navs.present?
          puts "---> cloning #{navs.length} custom shape nav"
          navs.each do |nav|
            nav.clone_for_event(self.id)
          end
        end

      end
    end
  end

  # determine if this event contains a summary indicator type
  def has_summary_indicator?
    types = IndicatorType.select('distinct has_summary').joins(:indicators => :event).where('events.id = ?', self.id)
    return types.present? && types.map{|x| x.has_summary}.index(true).present? ? true : false
  end


  # doing event.destroy takes a long time due to all the indciators and data
  # this method will be quicker for it uses delete instead of destroy when there can be lots of records to delete
  def destroy

    # get core ids only in event
    # - have to get it here before indicators are deleted
    core_ids_in_event = Indicator.where(:event_id => self.id).pluck(:core_indicator_id).uniq.sort
    core_ids_not_in_event = Indicator.where(['event_id != ?', self.id]).pluck(:core_indicator_id).uniq.sort

    # if the core dies not in event have a parent, add the parent id to the list
    core_ids_not_in_event_parents = CoreIndicator.where(['id in (?) and ancestry is not null', core_ids_not_in_event]).map{|x| x.root_id}.uniq.sort
    core_ids_not_in_event = (core_ids_not_in_event + core_ids_not_in_event_parents).flatten.uniq.sort
    puts "core_ids_in_event       #{core_ids_in_event}"
    puts "core_ids_not_in_event   #{core_ids_not_in_event}"
    core_ids_only_in_event = core_ids_in_event - core_ids_not_in_event
    puts "core_ids_only_in_event  #{core_ids_only_in_event}"


    puts "deleting event indicators and data"
    indicator_ids = Indicator.where(:event_id => self.id).pluck(:id)
    Datum.where(indicator_id: indicator_ids).delete_all
    IndicatorScale.where(indicator_id: indicator_ids).destroy_all
    Indicator.where(id: indicator_ids).delete_all

    puts "deleting event indicator relationships"
    EventIndicatorRelationship.where(:event_id => self.id).destroy_all

    puts "deleting core indicators that are just for this event"
    CoreIndicatorTranslation.where(core_indicator_id: core_ids_only_in_event).delete_all
    CoreIndicator.where(id: core_ids_only_in_event).delete_all

    puts "deleting misc (translations, live events, custom views, custom shape nav)"
    self.event_translations.delete_all
    self.menu_live_events.delete_all
    self.event_custom_views.destroy_all
    self.custom_shape_navigations.destroy_all

    puts "deleting the event"
    self.delete

    I18n.available_locales.each do |locale|
      JsonCache.clear_data_file("profiles/core_indicator_events_#{locale}")
      JsonCache.clear_data_file("profiles/core_indicator_events_table_#{locale}")
    end
  end
end
