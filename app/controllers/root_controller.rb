class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :region_districts]

  # GET /
  # GET /.json
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def map
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
		shape_type_id = 2

		# get the indicators
		if !params[:event_id].nil?
			@indicators = Indicator.where(:event_id => params[:event_id], :shape_type_id => shape_type_id)
		end

		render :layout => 'map'
  end

  # GET /events/admin
  # GET /events/admin.json
  def admin
	

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end


  def region_districts
    if params[:region_id].nil?
      return
    end
    path = File.dirname(__FILE__) + '/../../public/assets/json/districts_by_region.json';
    data = File.open(path, 'rb') { |f| f.read }
    data = ActiveSupport::JSON.decode data
    data =
    {
      'type' => 'FeatureCollection',
      'features' => data[params[:region_id].to_i]
    }

  # data = ActiveSupport::JSON.encode data
  # render :inline => data

    respond_to do |format|
      format.json { render json: data }
    end
  end

end
