class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :region_districts]

  # GET /
  # GET /.json
  def index

    respond_to do |format|
      format.html # index.html.erb
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
