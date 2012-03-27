class RootController < ApplicationController
  before_filter :authenticate_user!

  # GET /
  # GET /.json
	def index
		# get the event type id
		event_type_id = params[:event_type].nil? ? @event_types.first.id : params[:event_type]
		
		# get the event  name
		@event_types.each do |type|
			if type.id.to_s == event_type_id.to_s
				@event_type_name = type.name
				break
			end
		end

		# get the events
		@events = Event.where(:event_type_id => event_type_id)

		# get the shape type id
		shape_type_id = params[:shape_type].nil? ? @default_shape_type_id : params[:shape_type]

		# get the indicators
		if !params[:event_id].nil?
			@indicators = Indicator.where(:event_id => params[:event_id], :shape_type_id => shape_type_id)
		end

		# set js variables: shape id
    set_gon_variables
    
		render :layout => 'map'
	end

  # GET /events/shape/:id
  # GET /events/shape/:id.json
  def shape
		#get the parent shape
		shape = Shape.where(:id => params[:id])

    respond_to do |format|
      format.json { render json: Shape.build_json(shape) }
    end
  end

  # GET /events/children_shapes/:parent_id
  # GET /events/children_shapes/:parent_id.json
  def children_shapes
		geometries = ''

		#get the parent shape
		shape = Shape.where(:id => params[:parent_id])
		
		if !shape.nil? && shape.length > 0 && shape.first.has_children?
			# get all of the children of the parent and format for json
			geometries = Shape.build_json(shape.first.children)
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
    # shape id
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
    			gon.children_shapes_path = children_shapes_path(:parent_id => @default_shape_id)
    		else
    		  # found event, load its shape
    			gon.shape_path = shape_path(:id => event.shape_id)
    			gon.children_shapes_path = children_shapes_path(:parent_id => event.shape_id)
    		end
      else
        # no event selected yet, use default shape
  			gon.shape_path = shape_path(:id => @default_shape_id)
  			gon.children_shapes_path = children_shapes_path(:parent_id => @default_shape_id)
      end
    else
      # shape id is provided, use it
			gon.shape_path = shape_path(:id => params[:shape_id])
			gon.children_shapes_path = children_shapes_path(:parent_id => params[:shape_id])
    end
  end
end
