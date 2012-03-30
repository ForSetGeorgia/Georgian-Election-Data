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

	# get count of indicator scales for indicator
	def self.count_by_indicator(indicator_id)
		where(:indicator_id => indicator_id).count
	end

	# get an array of colors to use with the scales
  def self.get_colors(indicator_id)
		if !indicator_id.nil?
			# get the number of scales for the provided indicator_id
			num_levels = count_by_indicator(indicator_id)
logger.debug "num of indicator scales = #{num_levels}"
			if !num_levels.nil?
				colors = []
				case num_levels
				when 3
					colors = ["#FEE8C8", "#FDBB84", "#E34A33"]
				when 4
					colors = ["#FEF0D9", "#FDCC8A", "#FC8D59", "#D7301F"]
				when 5 
					colors = ["#FEF0D9", "#FDCC8A", "#FC8D59", "#E34A33", "#B30000"]
				when 6
					colors = ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#E34A33", "#B30000"]
				when 7
					colors = ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"]
				when 8
					colors = ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"]
				when 9
					colors = ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#B30000", "#7F0000"]
				end
				return colors
			end
		end
		return nil
	end
end
