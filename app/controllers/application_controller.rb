class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  before_filter :set_election_types
  before_filter :set_shape_types
  before_filter :set_default_values
  
  def set_locale
    I18n.locale = params[:locale] if params[:locale]
    @locales = Locale.all
  end
  
  def set_election_types
    @event_types = EventType.all
  end
  
  def set_default_values
    @default_shape_id = 175
		@default_shape_type_id = 1
  end
  
  def set_shape_types
    @shape_types = ShapeType.all
  end
  
  def default_url_options(options={})
    { :locale => I18n.locale }
  end

end
