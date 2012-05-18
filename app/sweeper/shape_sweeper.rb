class ShapeSweeper < ActionController::Caching::Sweeper
  observe Shape # This sweeper is going to keep an eye on the Shape model
 
  # If our sweeper detects that a Shape was created call this
  def after_create(shape_type)
    expire_cache_for(shape_type)
  end
 
  # If our sweeper detects that a Shape was updated call this
  def after_update(shape_type)
    expire_cache_for(shape_type)
  end
 
  # If our sweeper detects that a Shape was deleted call this
  def after_destroy(shape_type)
    expire_cache_for(shape_type)
  end
 
  private
  def expire_cache_for(shape_type)
		Rails.cache.clear
  end
end