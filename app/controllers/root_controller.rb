class RootController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]

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

end
