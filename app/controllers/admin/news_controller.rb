class Admin::NewsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end
	require 'data_archive'

  # GET /news
  # GET /news.json
  def index
    @news = News.recent.with_translations(I18n.locale).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/new
  # GET /news/new.json
  def new
    @news = News.new

    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@news.news_translations.build(:locale => locale)
		end

		gon.edit_news = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1/edit
  def edit
    @news = News.find(params[:id])

		# turn the datetime picker js on
		# have to format dates this way so js datetime picker read them properly
		gon.edit_news = true
		gon.date_posted = @news.date_posted.strftime('%m/%d/%Y %H:%M') if !@news.date_posted.nil?
		gon.data_archive = @news_types[:data_archive]
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(params[:news])

    respond_to do |format|
      if @news.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.news'))
				send_status_update(msg)
        format.html { redirect_to admin_news_index_path, notice: msg }
        format.json { render json: @news, status: :created, location: @news }
      else
				# turn the datetime picker js on
				# have to format dates this way so js datetime picker read them properly
				gon.edit_news = true
				gon.date_posted = @news.date_posted.strftime('%m/%d/%Y %H:%M') if !@news.date_posted.nil?
				gon.data_archive = @news_types[:data_archive]

        format.html { render action: "new" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.json
  def update
    @news = News.find(params[:id])

    respond_to do |format|
      if @news.update_attributes(params[:news])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.news'))
				send_status_update(msg)
        format.html { redirect_to admin_news_index_path, notice: msg }
        format.json { head :ok }
      else
				# turn the datetime picker js on
				# have to format dates this way so js datetime picker read them properly
				gon.edit_news = true
				gon.date_posted = @news.date_posted.strftime('%m/%d/%Y %H:%M') if !@news.date_posted.nil?
				gon.data_archive = @news_types[:data_archive]

        format.html { render action: "edit" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news = News.find(params[:id])
    @news.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.news'))
		send_status_update(msg)
    respond_to do |format|
      format.html { redirect_to admin_news_index_url }
      format.json { head :ok }
    end
  end

end
