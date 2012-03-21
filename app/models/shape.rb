class Shape < ActiveRecord::Base
  translates :name

  has_many :shape_translations
  belongs_to :shape_type
  accepts_nested_attributes_for :shape_translations
  attr_accessible :parent_id, :shape_type_id, :common_id, :geo_data, :shape_translations_attributes
  attr_accessor :locale

  validates :shape_type_id, :common_id, :geo_data, :presence => true
  
  scope :l10n , joins(:shape_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n
end
