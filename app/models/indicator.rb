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


  def self.build_from_csv(row)
    # see if indicator already exists for the provided event and shape_type

		# get the event id
		event = Event.find_by_name(row[0])
		# get the shape type id
		shape_type = ShapeType.find_by_name(row[1])

		if event.nil? || shape_type.nil?
logger.debug "event or shape type was not found"				
		else

			# populate record
			ind = Indicator.new
			ind.event_id = event.id
			ind.shape_type_id = shape_type.id
			ind.indicator_translations.build(:locale => 'en', :name => row[2], :name_abbrv => row[3])
			ind.indicator_translations.build(:locale => 'ka', :name => row[4], :name_abbrv => row[5])

logger.debug "indicator has #{ind.indicator_translations.length} translations"
logger.debug "created the indicator object, returning"
		  return ind
		end
  end
  
end
