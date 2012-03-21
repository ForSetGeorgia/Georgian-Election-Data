class ShapeTranslation < ActiveRecord::Base
  attr_accessible :shape_id, :name, :locale
  belongs_to :shape

  validates :name, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the event is created.  probably way to fix
#  validates :shape_id, :presence => true  

  default_scope order('locale ASC, name ASC')
end
