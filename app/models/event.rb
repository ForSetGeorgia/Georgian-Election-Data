class Event < ActiveRecord::Base
  translates :name

  has_many :indicators
  belongs_to :shape
  accepts_nested_attributes_for :event_translations
  attr_accessible :shape_id , :event_translations_attributes
  attr_accessor :locale

  validates :start_shape_id, :presence => true
  
  scope :l10n , joins(:event_translations).where('locale = ?',I18n.locale)
  scope :by_title , order('name').l10n
end
