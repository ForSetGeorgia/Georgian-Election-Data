# encoding: UTF-8
class AddShapeTypeInField < ActiveRecord::Migration
  def up
    add_column :shape_type_translations, :name_singular_in, :string
  
    # add data
    ka_text = Hash.new
    ka_text['თბილისი ოლქი'] = 'თბილისის ოლქში'
    ka_text['თბილისის უბანი'] = 'თბილისის უბანში'
    ka_text['მაჟორიტარული თბილისის ოლქი'] = 'თბილისის მაჟორიტარულ ოლქში'
    ka_text['მაჟორიტარული თბილისის უბანი'] = 'თბილისის მაჟორიტარულ უბანში'
    ka_text['მაჟორიტარული ოლქი'] = 'მაჟორიტარულ ოლქში'
    ka_text['მაჟორიტარული უბანი'] = 'მაჟორიტარულ უბანში'
    ka_text['ოლქი'] = 'ოლქში'
    ka_text['რეგიონი'] = 'რეგიონში'
    ka_text['უბანი'] = 'უბანში'
    ka_text['ქვეყანა'] = 'ქვეყანაში'
    
    ShapeTypeTranslation.transaction do 
      ShapeTypeTranslation.all.each do |trans|
        if trans.locale == 'en'
          trans.name_singular_in = 'in ' + trans.name_singular
        else
          trans.name_singular_in = ka_text[trans.name_singular]
          
          # fix some names while in here
          if trans.name_singular == 'მაჟორიტარული თბილისის ოლქი'
            trans.name_singular = 'თბილისის მაჟორიტარული  ოლქი'
            trans.name_plural = 'თბილისის მაჟორიტარული  ოლქები'
            trans.name_singular_possessive = 'თბილისის მაჟორიტარული ოლქის'
          end
          
          if trans.name_singular == 'მაჟორიტარული თბილისის უბანი'
            trans.name_singular = 'თბილისის მაჟორიტარული  უბანი'
            trans.name_plural = 'თბილისის მაჟორიტარული  უბნები'
            trans.name_singular_possessive = 'თბილისის მაჟორიტარული უბნის'
          end
          
          
        end
        trans.save      
      end
    end  
  end

  def down
    remove_column :shape_type_translations, :name_singular_in
  end
end
