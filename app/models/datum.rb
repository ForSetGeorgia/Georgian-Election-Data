class Datum < ActiveRecord::Base
  belongs_to :indicator

  attr_accessible :indicator_id, :common_id, :value

  validates :indicator_id, :common_id, :value, :presence => true
end
