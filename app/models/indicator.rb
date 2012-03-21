class Indicator < ActiveRecord::Base
  translates :name, :name_abbrv

  has_many :indicator_scales
  has_many :data
  has_many :indicator_translations
  belongs_to :event
  belongs_to :shape_type_id
  accepts_nested_attributes_for :indicator_translations
  attr_accessible :event_id, :shape_type_id , :indicator_translations_attributes
  attr_accessor :locale

  validates :event_id, :shape_type_id, :presence => true
  
  scope :l10n , joins(:indicator_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n
end
