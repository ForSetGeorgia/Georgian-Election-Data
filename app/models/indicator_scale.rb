class IndicatorScale < ActiveRecord::Base
  belongs_to :indicator

  attr_accessible :indicator_id, :max, :min

  validates :indicator_id, :max, :min, :presence => true
  
end
