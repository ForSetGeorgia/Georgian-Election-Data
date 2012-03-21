class Locale < ActiveRecord::Base
  attr_accessible :name, :language
  validates :language, :name, :presence => true
  
  default_scope order('language ASC')
end
