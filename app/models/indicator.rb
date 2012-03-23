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
    "Event, Shape Type, en: Indicator Name, en: Indicator Abbrv, ka: Indicator Name, ka: Indicator Abbrv, en: Scale Name, ka: Scale Name, en: Scale Name, ka: Scale Name".split(",")
  end

  def self.build_from_csv(file)
    infile = file.read
    n, msg = 0, ""

		Indicator.transaction do
		  CSV.parse(infile) do |row|
		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?

				# get the event id
				event = Event.find_by_name(row[0].strip)
				# get the shape type id
				shape_type = ShapeType.find_by_name(row[1].strip)

				if event.nil? || shape_type.nil?
	logger.debug "event or shape type was not found"				
    		  msg = "Row #{n} - The event or shape type was not found."
		      raise ActiveRecord::Rollback
    		  return msg
				else
	logger.debug "found event and shape type, seeing if record already exists"
					# see if indicator already exists for the provided event and shape_type
					alreadyExists = Indicator.includes(:indicator_translations)
					  .where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
					    event.id, shape_type.id, row[2].strip)
					
					if alreadyExists.nil? || alreadyExists.length == 0
	logger.debug "record does not exist, populate obj"
						# populate record
						ind = Indicator.new
						ind.event_id = event.id
						ind.shape_type_id = shape_type.id
					  # translations
						ind.indicator_translations.build(:locale => 'en', :name => row[2].strip, :name_abbrv => row[3].strip)
						ind.indicator_translations.build(:locale => 'ka', :name => row[4].strip, :name_abbrv => row[5].strip)
					  # scales
					  finishedScales = false # keep looping until find empty cell
					  i = 6 # where first scale starts
					  until finishedScales do
					    if row[i].nil? || row[i+1].nil?
					      # found empty cell, stop
					      finishedScales = true
					    else
					      # found scale, add it
					      scale = ind.indicator_scales.build
								scale.indicator_scale_translations.build(:locale => 'en', :name => row[i].strip)
								scale.indicator_scale_translations.build(:locale => 'ka', :name => row[i+1].strip)
								i+=2 # move on to the next set of indicator scales
					    end
					  end
		logger.debug "saving record"
					  # Save if valid 
				    if ind.valid?
				      ind.save
				    else
				      # an error occurred, stop
				      msg = "Row #{n} is not valid."
				      raise ActiveRecord::Rollback
				      return msg
				    end
					else
		logger.debug "**record already exists!"
			      msg = "Row #{n} already exists in the database."
			      raise ActiveRecord::Rollback
			      return msg
					end
				end
			end
		end
  logger.debug "procssed #{n} rows in CSV file"
    return msg 
  end
end
