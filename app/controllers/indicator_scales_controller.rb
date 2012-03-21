class IndicatorScalesController < ApplicationController
  before_filter :authenticate_user!

  # GET /indicator_scales
  # GET /indicator_scales.json
  def index
    @indicator_scales = IndicatorScale.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @indicator_scales }
    end
  end

  # GET /indicator_scales/1
  # GET /indicator_scales/1.json
  def show
    @indicator_scale = IndicatorScale.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @indicator_scale }
    end
  end

  # GET /indicator_scales/new
  # GET /indicator_scales/new.json
  def new
    @indicator_scale = IndicatorScale.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @indicator_scale }
    end
  end

  # GET /indicator_scales/1/edit
  def edit
    @indicator_scale = IndicatorScale.find(params[:id])
  end

  # POST /indicator_scales
  # POST /indicator_scales.json
  def create
    @indicator_scale = IndicatorScale.new(params[:indicator_scale])

    respond_to do |format|
      if @indicator_scale.save
        format.html { redirect_to @indicator_scale, notice: 'Indicator scale was successfully created.' }
        format.json { render json: @indicator_scale, status: :created, location: @indicator_scale }
      else
        format.html { render action: "new" }
        format.json { render json: @indicator_scale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /indicator_scales/1
  # PUT /indicator_scales/1.json
  def update
    @indicator_scale = IndicatorScale.find(params[:id])

    respond_to do |format|
      if @indicator_scale.update_attributes(params[:indicator_scale])
        format.html { redirect_to @indicator_scale, notice: 'Indicator scale was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @indicator_scale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicator_scales/1
  # DELETE /indicator_scales/1.json
  def destroy
    @indicator_scale = IndicatorScale.find(params[:id])
    @indicator_scale.destroy

    respond_to do |format|
      format.html { redirect_to indicator_scales_url }
      format.json { head :ok }
    end
  end
end
