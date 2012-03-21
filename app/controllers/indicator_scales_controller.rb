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
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    @locales.length.times {@indicator_scale.indicator_scale_translations.build}

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

    # GET /indicator_scales/upload
    # GET /indicator_scales/upload.json
    def upload
  		if request.post? && params[:file].present?
  logger.debug "content type = #{params[:file].content_type}"
  			if params[:file].content_type == "text/csv"
  logger.debug "content type is CSV, processing"

  		    infile = params[:file].read
  		    n, errs = 0, ""

  				IndicatorScale.transaction do
  				  CSV.parse(infile) do |row|
  				    n += 1
  				    # SKIP: header i.e. first row OR blank row
  				    next if n == 1 or row.join.blank?
  				    # build new indicator record
  				    ind_scale = IndicatorScale.build_from_csv(row)
  				    # Save upon valid 
  				    # otherwise collect error records to export
              if !ind_scale.nil?
    				    if ind_scale.valid?
    				      ind_scale.save
    				    else
    				      # an error occurred, stop
    				      errs = "Row #{n} is not valid."
    				      raise ActiveRecord::Rollback
    				      break
    				    end
  			      else
    			      # an error occurred, stop
    			      errs = "Row #{n} has an event or shape type that is not in the database or the indicator already exists."
    			      raise ActiveRecord::Rollback
    			      break
              end
  				  end
  				end
  logger.debug " - processed #{n} rows"
  		    if errs.length > 0
  logger.debug " - errors found!"
  					flash[:notice] = "Errors were encountered and no records were saved.  The problem was the following: #{errs}"
  		      redirect_to upload_indicator_scales_path #GET
  		    else
  logger.debug " - no errors found!"
  					flash[:notice] = "Your file was successfully processed!"
  		      redirect_to upload_indicator_scales_path #GET
  		    end
  			else
  logger.debug "content type is NOT CSV, stopping"
  				flash[:notice] = "Your file must be a CSV format."
          redirect_to upload_indicator_scales_path #GET
  			end
  		end
    end

end
