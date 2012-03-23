class Datum < ActiveRecord::Base
  belongs_to :indicator

  attr_accessible :indicator_id, :common_id, :value

  validates :indicator_id, :common_id, :value, :presence => true


  def self.csv_header
    "Event, Shape Type, Common ID, Indicator, Value, Indicator, Value".split(",")
  end

  def self.build_from_csv(file)
    infile = file.read
    n, msg = 0, ""

		Datum.transaction do
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
		logger.debug "event and shape found, procesing indicators"
					finishedIndicators = false
					i = 3 # where first indicator starts

					until finishedIndicators do
					  if row[i].nil? || row[i+1].nil?
		logger.debug "found empty cells, stopping processing for row"
					    # found empty cell, stop
					    finishedIndicators = true
					  else
		logger.debug "seeing if indicator already exists"
							# see if indicator already exists for the provided event and shape_type
							indicator = Indicator.includes(:indicator_translations)
								.where('indicators.event_id = ? and indicators.shape_type_id = ? and indicator_translations.locale="en" and indicator_translations.name= ?', 
									event.id, shape_type.id, row[i].strip)
					
							if indicator.nil?
			logger.debug "indicator was not found"
							  msg = "Row #{n} - The indicator could not be found."
								raise ActiveRecord::Rollback
							  return msg
							else
			logger.debug "indicator found, checking if data exists"
								# check if data already exists
								alreadyExists = Datum.where(:indicator_id => indicator.first.id, :common_id => row[2].strip)
					
								if alreadyExists.nil? || alreadyExists.length == 0
			logger.debug "data does not exist, save it"
									# populate record
									datum = Datum.new
									datum.indicator_id = indicator.first.id
									datum.common_id = row[2].strip
									datum.value = row[i+1].strip

		logger.debug "saving record"
									if datum.valid?
									  datum.save
									else
									  # an error occurred, stop
									  errs = "Row #{n} is not valid."
									  raise ActiveRecord::Rollback
									  break
									end

									i+=2 # move on to the next set of indicator/value pairs
								else
		logger.debug "**record already exists!"
									msg = "Row #{n} already exists in the database."
									raise ActiveRecord::Rollback
									return msg
								end
							end
						end
					end
				end
			end
		end
  logger.debug "procssed #{n} rows in CSV file"
    return msg 
  end

end
