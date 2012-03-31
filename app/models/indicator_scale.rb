class IndicatorScale < ActiveRecord::Base
  translates :name
  require 'csv'

  belongs_to :indicator
  has_many :indicator_scale_translations
  accepts_nested_attributes_for :indicator_scale_translations
  attr_accessible :indicator_id, :indicator_scale_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:indicator_scale_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n

  # have to turn this off so csv upload works since adding indicator and scale at same time, no indicator id exists yet
  #validates :indicator_id, :presence => true

	# get count of indicator scales for indicator
	def self.count_by_indicator(indicator_id)
		where(:indicator_id => indicator_id).count
	end

	# get an array of colors to use with the scales
	# colors are from http://colorbrewer2.org/
  def self.get_colors(indicator_id)
		if !indicator_id.nil?
			# get the number of scales for the provided indicator_id
			num_levels = count_by_indicator(indicator_id)
logger.debug "+++ num of indicator scales = #{num_levels}"
			if !num_levels.nil?
				colors = []
				case num_levels
				when 3
					colors = ["#FEE8C8", "#FDBB84", "#E34A33"]
				when 4
					colors = ["#FEF0D9", "#FDCC8A", "#FC8D59", "#D7301F"]
				when 5 
					colors = ["#FEF0D9", "#FDCC8A", "#FC8D59", "#E34A33", "#B30000"]
				when 6
					colors = ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#E34A33", "#B30000"]
				when 7
					colors = ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"]
				when 8
					colors = ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"]
				when 9
					colors = ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#B30000", "#7F0000"]
				end
				return colors
			end
		end
		return nil
	end
	
  def self.csv_header
    "Event, Shape Type, en: Indicator Name, en: Scale Name, ka: Scale Name, en: Scale Name, ka: Scale Name".split(",")
  end

  def self.build_from_csv(file, deleteExistingScales)
    infile = file.read
    n, msg = 0, ""

		IndicatorScale.transaction do
		  CSV.parse(infile) do |row|
		    n += 1
		    # SKIP: header i.e. first row OR blank row
		    next if n == 1 or row.join.blank?

				# get the event id
				event = Event.find_by_name(row[0].strip)
				# get the shape type id
				shape_type = ShapeType.find_by_name(row[1].strip)

				if event.nil? || shape_type.nil?
	logger.debug "+++ event or shape type was not found"				
    		  msg = "Row #{n} - The event or shape type was not found."
		      raise ActiveRecord::Rollback
    		  return msg
				else
	logger.debug "+++ found event and shape type, seeing if indicator record exists"
					# see if indicator exists for the provided event and shape_type
					alreadyExists = Indicator.includes(:indicator_translations)
						.where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
							event.id, shape_type.id, row[2].strip)
					
					if !alreadyExists.nil? && alreadyExists.length > 0
	logger.debug "+++ indicator record exists, populate scales"
	          indicator = alreadyExists[0]
            if deleteExistingScales
              # if the indicator already has scales, delete them
              if indicator.indicator_scales.length > 0
	logger.debug "+++ deleting existing idicator scales"
                # delete the scales
                IndicatorScale.delete_all (["indicator_id = ?", indicator.id])
              end
            end
						# populate record
					  finishedScales = false # keep looping until find empty cell
					  i = 3 # where first scale starts
					  until finishedScales do
					    if row[i].nil? || row[i+1].nil?
					      # found empty cell, stop
					      finishedScales = true
					    else
					      # found scale, add it
					      scale = indicator.indicator_scales.build
								scale.indicator_scale_translations.build(:locale => 'en', :name => row[i].strip)
								scale.indicator_scale_translations.build(:locale => 'ka', :name => row[i+1].strip)
								i+=2 # move on to the next set of indicator scales
					    end
					  end
					  # only save scales if there were between 3 and 9
					  if i >= 7 || i <= 19
  		logger.debug "+++ saving record"
  					  # Save if valid 
  				    if indicator.valid?
  				      indicator.save
  				    else
  				      # an error occurred, stop
  				      msg = "Row #{n} is not valid."
  				      raise ActiveRecord::Rollback
  				      return msg
  				    end
				    else
				      # scales out of range, stop
				      msg = "Row #{n} must have between 3 and 9 indicator scales."
				      raise ActiveRecord::Rollback
				      return msg
				    end
					else
		logger.debug "+++ **record does not exist!"
			      msg = "Row #{n} indicator does not already exists in the database."
			      raise ActiveRecord::Rollback
			      return msg
					end
				end
			end
		end
  logger.debug "+++ procssed #{n} rows in CSV file"
    return msg 
  end
	
	
end
