class RootController < ApplicationController
  before_filter :authenticate_user!

  # GET /
  # GET /.json
	def index
		# get the event type id
		event_type_id = params[:event_type_id].nil? ? @event_types.first.id : params[:event_type_id]
		
		# get the event type name
		@event_types.each do |type|
			if type.id.to_s == event_type_id.to_s
				@event_type_name = type.name
				break
			end
		end

		# get the events
		@events = Event.where(:event_type_id => event_type_id)

		# get the shape type id that was clicked
		parent_shape_type_id = params[:shape_type_id].nil? ? @default_shape_type_id : params[:shape_type_id]
		# now get the shape type id that is the child
		shape_type = ShapeType.find(parent_shape_type_id)
		shape_type_id = nil
		if (!shape_type.nil? && shape_type.has_children?)
			# found child, save id
			shape_type_id = shape_type.children.first.id
		end

		# get the indicators for the children shape_type
		if !params[:event_id].nil? && !shape_type_id.nil?
			@indicators = Indicator.where(:event_id => params[:event_id], :shape_type_id => shape_type_id)
		end

		# if a shape was clicked on, update the indicator_id to be valid for the new shape_type
		if !params[:shape_click].nil? && params[:shape_click] == "true"
			# we know the parent indicator id and the new shape type
			# - use that to find the new indicator id
			@child_indicator = Indicator.find_new_id(params[:indicator_id], shape_type_id)
			if @child_indicator.nil? || @child_indicator.length == 0
				# could not find a match, reset the indicator id
				params[:indicator_id] = nil
			else
				# save the new value				
				params[:indicator_id] = @child_indicator.first.id
			end
		end

		# reset the shape click parameter
		# - used to indicate that the page is loading due to a shape being clicked on
		params[:shape_click] = false

		# set js variables
    set_gon_variables
    
		render :layout => 'map'
	end

  # GET /events/shape/:id
  # GET /events/shape/:id.json
  def shape
		#get the parent shape
logger.debug("indicator id = #{params[:indicator_id]}")
		shape = Shape.where(:id => params[:id])
    respond_to do |format|
      format.json { render json: Shape.build_json(shape, params[:indicator_id]) }
    end
  end

  # GET /events/children_shapes/:parent_id
  # GET /events/children_shapes/:parent_id.json
  def children_shapes
logger.debug("indicator id = #{params[:indicator_id]}")
		geometries = ''

		#get the parent shape
		shape = Shape.where(:id => params[:parent_id])
		
		if !shape.nil? && shape.length > 0 && shape.first.has_children?
			# get all of the children of the parent and format for json
			geometries = Shape.build_json(shape.first.children, params[:indicator_id])
		end

    respond_to do |format|
      format.json { render json: geometries}
    end
  end

  # GET /events/admin
  # GET /events/admin.json
  def admin

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end


private

  def set_gon_variables
    # shape json paths
		# - only chilrend shape path needs the indicator id since that is the only layer that is clickable
    if params[:shape_id].nil?
      # shape id is not provided, find the shape assigned to the event
  		event = nil
  		if !params[:event_id].nil?
    		@events.each do |ev|
    			if ev.id.to_s == params[:event_id]
    				event = ev 
    				break
    			end
    		end
    		if event.nil? || event.shape_id.nil?
    			# set default
          # no event selected or event does not have a shape assigned to it, using defaults for gon variables
    			gon.shape_path = shape_path(:id => @default_shape_id)
    			gon.children_shapes_path = children_shapes_path(:parent_id => @default_shape_id, :indicator_id => params[:indicator_id])
    		else
    		  # found event, load its shape
    			gon.shape_path = shape_path(:id => event.shape_id)
    			gon.children_shapes_path = children_shapes_path(:parent_id => event.shape_id, :indicator_id => params[:indicator_id])
    		end
      else
        # no event selected yet, use default shape
  			gon.shape_path = shape_path(:id => @default_shape_id)
  			gon.children_shapes_path = children_shapes_path(:parent_id => @default_shape_id, :indicator_id => params[:indicator_id])
      end
    else
      # shape id is provided, use it
			gon.shape_path = shape_path(:id => params[:shape_id])
			gon.children_shapes_path = children_shapes_path(:parent_id => params[:shape_id], :indicator_id => params[:indicator_id])
    end

		# indicator scales
		if !params[:indicator_id].nil?
			gon.showing_indicators = true
			build_indicator_scale_array
		else
			gon.showing_indicators = false
		end

  end

  # build an array of indicator scales that will be used in js
  def build_indicator_scale_array
    if !params[:indicator_id].nil?
      # get the scales
      scales = IndicatorScale.where(:indicator_id => params[:indicator_id])
      if !scales.nil? && scales.length > 0
        gon.indicator_scales = scales
      end
    end
  end

end
