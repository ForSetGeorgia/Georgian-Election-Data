class Datum < ActiveRecord::Base
  belongs_to :indicator

  attr_accessible :indicator_id, :common_id, :value

  validates :indicator_id, :common_id, :value, :presence => true


  def self.csv_header
    "Event, Shape Type, Common ID, Indicator, Value, Indicator, Value, ..."
  end

  def self.build_from_csv(row)
		data = []
		# get the event id
		event = Event.find_by_name(row[0])
		# get the shape type id
		shape_type = ShapeType.find_by_name(row[1])

		if event.nil? || shape_type.nil?
logger.debug "event or shape type was not found"				
      return nil
		else
			finishedIndicators = false
			i = 3 # where first indicator starts

			until finishedIndicators do
        if row[i].nil? || row[i+1].nil?
          # found empty cell, stop
          finishedIndicators = true
        else
				  # see if indicator already exists for the provided event and shape_type
				  indicator = Indicator.includes(:indicator_translations)
				    .where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
				      event.id, shape_type.id, row[i])
				  
				  if indicator.nil?
	logger.debug "indicator was not found"
				    return nil
					else
	logger.debug "indicator was found: #{indicator[0].id}"
						# check if data already exists
						alreadyExists = Datum.where(:indicator_id => indicator[0].id, :common_id => row[2])
						
			      if alreadyExists.nil? || alreadyExists.length == 0
							# populate record
							datum = Datum.new
							datum.indicator_id = indicator[0].id
							datum.common_id = row[2]
							datum.value = row[i+1]				
							# add to data array
							data << datum

							i+=2 # move on to the next set of indicator/value pairs
						else
logger.debug "**record already exists!"
						  return nil
						end
					end
				end
      end
		end
		logger.debug "created #{data.length} data objects, returning"
	  return data
  end
end
