class ShapesController < ApplicationController
  # GET /shapes
  # GET /shapes.json
  def index
    @shapes = Shape.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shapes }
    end
  end

  # GET /shapes/1
  # GET /shapes/1.json
  def show
    @shape = Shape.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shape }
    end
  end

  # GET /shapes/new
  # GET /shapes/new.json
  def new
    @shape = Shape.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shape }
    end
  end

  # GET /shapes/1/edit
  def edit
    @shape = Shape.find(params[:id])
  end

  # POST /shapes
  # POST /shapes.json
  def create
    @shape = Shape.new(params[:shape])

    respond_to do |format|
      if @shape.save
        format.html { redirect_to @shape, notice: 'Shape was successfully created.' }
        format.json { render json: @shape, status: :created, location: @shape }
      else
        format.html { render action: "new" }
        format.json { render json: @shape.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shapes/1
  # PUT /shapes/1.json
  def update
    @shape = Shape.find(params[:id])

    respond_to do |format|
      if @shape.update_attributes(params[:shape])
        format.html { redirect_to @shape, notice: 'Shape was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @shape.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shapes/1
  # DELETE /shapes/1.json
  def destroy
    @shape = Shape.find(params[:id])
    @shape.destroy

    respond_to do |format|
      format.html { redirect_to shapes_url }
      format.json { head :ok }
    end
  end
end
