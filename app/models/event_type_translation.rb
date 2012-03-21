class EventTypeTranslation < ActiveRecord::Base
  attr_accessible :event_type_id, :name, :locale
  belongs_to :event_type

  validates :name, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the event is created.  probably way to fix
#  validates :event_type_id, :presence => true  

  default_scope order('locale ASC, name ASC')
end
