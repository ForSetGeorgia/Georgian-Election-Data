class IndicatorScale < ActiveRecord::Base
  translates :name

  belongs_to :indicator
  has_many :indicator_scale_translations
  accepts_nested_attributes_for :indicator_scale_translations
  attr_accessible :indicator_id, :indicator_scale_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:indicator_scale_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n

  # have to turn this off so csv upload works since adding indicator and scale at same time, no indicator id exists yet
  #validates :indicator_id, :presence => true

  
end
