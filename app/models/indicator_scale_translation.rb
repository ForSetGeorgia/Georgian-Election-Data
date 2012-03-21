class IndicatorScaleTranslation < ActiveRecord::Base
  attr_accessible :indicator_scale_id, :name, :locale
  belongs_to :indicator_scale

  validates :name, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the event is created.  probably way to fix
#  validates :indicator_scale_id, :presence => true  

  default_scope order('locale ASC, name ASC')
end
