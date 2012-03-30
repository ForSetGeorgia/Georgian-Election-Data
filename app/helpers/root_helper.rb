module RootHelper

	# look through the current shape and its ancestry 
	# for the provided shape_type_id and return the 
	# id fo the shape that has the shape type
  def get_shape_id(shape_type_id)
logger.debug "current shape type = #{@shape.shape_type_id} and testing for shape type #{shape_type_id}"
		shape_type_child = @shape.shape_type.children
		if (!shape_type_child.nil?)
logger.debug "child shape type = #{shape_type_child.first.id}"
		  if shape_type_child.first.id == shape_type_id
				# it is the current shape
logger.debug "current shape is the correct shape"
				return @shape.id
			else
				# not the current shape, so look at ancestors
logger.debug "the shape has #{@shape.ancestors.count} ancestors"
				@shape.ancestors.each do |ancestor|
logger.debug "ancestor shape type = #{ancestor.shape_type_id}"
					if ancestor.shape_type_id == shape_type_id
logger.debug "matching shape type found in ancestor"
						# found the shape
						return ancestor.id
					end
				end
			end
		end
		return nil
  end

end
