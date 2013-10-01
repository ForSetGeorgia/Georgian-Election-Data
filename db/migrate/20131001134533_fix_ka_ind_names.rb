# encoding: UTF-8
class FixKaIndNames < ActiveRecord::Migration
  require 'json_cache'
  def up
    CoreIndicatorTranslation.transaction do
      trans = CoreIndicatorTranslation.find_by_name('ქრისტიანულ-დემოკრატიული მოძრაობა')
      if trans.present?
        trans.name = 'ქრისტიან-დემოკრატიული მოძრაობა'
        trans.description = trans.description.gsub('ქრისტიანულ-დემოკრატიული მოძრაობა', 'ქრისტიან-დემოკრატიული მოძრაობა') 
        trans.save
      end

      trans = CoreIndicatorTranslation.find_by_name('საქართველოს ეროვნულ დემოკრატიული პარტია')
      if trans.present?
        trans.name = 'საქართველოს ეროვნულ-დემოკრატიული პარტია'
        trans.description = trans.description.gsub('საქართველოს ეროვნულ დემოკრატიული პარტია', 'საქართველოს ეროვნულ-დემოკრატიული პარტია') 
        trans.save
      end

      trans = CoreIndicatorTranslation.find_by_name('სრულიად საქართველოს რადიკალ დემოკრატთა ნაციონალური პარტია')
      if trans.present?
        trans.name = 'სრულიად საქართველოს რადიკალ-დემოკრატთა ნაციონალური პარტია'
        trans.description = trans.description.gsub('სრულიად საქართველოს რადიკალ დემოკრატთა ნაციონალური პარტია', 'სრულიად საქართველოს რადიკალ-დემოკრატთა ნაციონალური პარტია') 
        trans.save
      end

      JsonCache.clear_data_files
    end
  end

  def down
    CoreIndicatorTranslation.transaction do
      trans = CoreIndicatorTranslation.find_by_name('ქრისტიან-დემოკრატიული მოძრაობა')
      if trans.present?
        trans.name = 'ქრისტიანულ-დემოკრატიული მოძრაობა'
        trans.description = trans.description.gsub('ქრისტიან-დემოკრატიული მოძრაობა', 'ქრისტიანულ-დემოკრატიული მოძრაობა') 
        trans.save
      end

      trans = CoreIndicatorTranslation.find_by_name('საქართველოს ეროვნულ-დემოკრატიული პარტია')
      if trans.present?
        trans.name = 'საქართველოს ეროვნულ დემოკრატიული პარტია'
        trans.description = trans.description.gsub('საქართველოს ეროვნულ-დემოკრატიული პარტია', 'საქართველოს ეროვნულ დემოკრატიული პარტია') 
        trans.save
      end

      trans = CoreIndicatorTranslation.find_by_name('სრულიად საქართველოს რადიკალ-დემოკრატთა ნაციონალური პარტია')
      if trans.present?
        trans.name = 'სრულიად საქართველოს რადიკალ დემოკრატთა ნაციონალური პარტია'
        trans.description = trans.description.gsub('სრულიად საქართველოს რადიკალ-დემოკრატთა ნაციონალური პარტია', 'სრულიად საქართველოს რადიკალ დემოკრატთა ნაციონალური პარტია') 
        trans.save
      end

      JsonCache.clear_data_files
    end
  end
end
