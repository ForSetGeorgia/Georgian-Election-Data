class IndicatorScale < ActiveRecord::Base
  translates :name

  belongs_to :indicator
  has_many :indicator_scale_translations
  accepts_nested_attributes_for :indicator_scale_translations
  attr_accessible :indicator_id, :indicator_scale_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:indicator_scale_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n

  validates :indicator_id, :presence => true
  
    def self.build_from_csv(row)
  		# see if the indicator already exists
  		indicator = Indicator.find_by_event_shape_type_name(row[0], row[1], row[2], 'en')
      
  		if indicator.nil? || indicator.length == 0
  logger.debug "indicator was not found"				
        return nil
  		else
logger.debug "indicator id found: #{indicator[0].id}"				
        # see if indicator scale already exists for the provided indicator
        alreadyExists = IndicatorScale.includes(:indicator_scale_translations)
          .where('indicator_scales.indicator_id = ? and indicator_scale_translations.locale="en" and indicator_scale_translations.name= ?', 
            indicator[0].id, row[2])

        if alreadyExists.nil? || alreadyExists.length == 0
    			# populate record
    			ind_scale = IndicatorScale.new
    			ind_scale.indicator_id = indicator[0].id
    			ind_scale.indicator_scale_translations.build(:locale => 'en', :name => row[3])
    			ind_scale.indicator_scale_translations.build(:locale => 'ka', :name => row[4])

  logger.debug "indicator scale has #{ind_scale.indicator_scale_translations.length} translations"
  logger.debug "created the indicator scale object, returning"
    		  return ind_scale
        else
  logger.debug "**record already exists!"
          return nil
        end
  		end
    end
end
