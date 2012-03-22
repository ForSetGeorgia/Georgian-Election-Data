class Indicator < ActiveRecord::Base
  translates :name, :name_abbrv

  has_many :indicator_scales
  has_many :data
  has_many :indicator_translations
  belongs_to :event
  belongs_to :shape_type
  accepts_nested_attributes_for :indicator_translations
  attr_accessible :event_id, :shape_type_id , :indicator_translations_attributes
  attr_accessor :locale

  validates :event_id, :shape_type_id, :presence => true
  
  scope :l10n , joins(:indicator_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n


  def self.csv_header
    "Event, Shape Type, en: Indicator Name, en: Indicator Abbrv, ka: Indicator Name, ka: Indicator Abbrv, en: Scale Name, ka: Scale Name, en: Scale Name, ka: Scale Name, ..."
  end

  def self.build_from_csv(row)
		# get the event id
		event = Event.find_by_name(row[0])
		# get the shape type id
		shape_type = ShapeType.find_by_name(row[1])

		if event.nil? || shape_type.nil?
logger.debug "event or shape type was not found"				
      return nil
		else
      # see if indicator already exists for the provided event and shape_type
      alreadyExists = Indicator.includes(:indicator_translations)
        .where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
          event.id, shape_type.id, row[2])
      
      if alreadyExists.nil? || alreadyExists.length == 0
  			# populate record
  			ind = Indicator.new
  			ind.event_id = event.id
  			ind.shape_type_id = shape_type.id
        # translations
  			ind.indicator_translations.build(:locale => 'en', :name => row[2], :name_abbrv => row[3])
  			ind.indicator_translations.build(:locale => 'ka', :name => row[4], :name_abbrv => row[5])
logger.debug "indicator has #{ind.indicator_translations.length} translations"
        # scales
        finishedScales = false # keep looping until find empty cell
        i = 6
        until finishedScales do
          if row[i].nil? || row[i+1].nil?
            # found empty cell, stop
            finishedScales = true
          else
            # found scale, add it
            scale = ind.indicator_scales.build
      			scale.indicator_scale_translations.build(:locale => 'en', :name => row[i])
      			scale.indicator_scale_translations.build(:locale => 'ka', :name => row[i+1])
      			i+=2
          end
        end
logger.debug "indicator has #{ind.indicator_scales.length} scales"

logger.debug "created the indicator object, returning"
  		  return ind
      else
logger.debug "**record already exists!"
        return nil
      end
		end
  end
end
