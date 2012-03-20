class ShapeType < ActiveRecord::Base
  translates :name

  has_many :indicators
  has_many :shapes
  has_many :shape_type_translations
  accepts_nested_attributes_for :shape_type_translations
  attr_accessible :shape_type_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:shape_type_translations).where('locale = ?',I18n.locale)
  scope :by_title , order('title').l10n
end
