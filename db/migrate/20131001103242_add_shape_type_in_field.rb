# encoding: UTF-8
class AddShapeTypeInField < ActiveRecord::Migration
  def up
    add_column :shape_type_translations, :name_singular_in, :string
  
    # add data
    ka_text = Hash.new
    ka_text['თბილისი ოლქი'] = 'თბილისი ოლქი'
    ka_text['თბილისის უბანი'] = 'თბილისის უბანი'
    ka_text['მაჟორიტარული თბილისის ოლქი'] = 'მაჟორიტარული თბილისის ოლქი'
    ka_text['მაჟორიტარული თბილისის უბანი'] = 'მაჟორიტარული თბილისის უბანი'
    ka_text['მაჟორიტარული ოლქი'] = 'მაჟორიტარული ოლქი'
    ka_text['მაჟორიტარული უბანი'] = 'მაჟორიტარული უბანი'
    ka_text['ოლქი'] = 'ოლქი'
    ka_text['რეგიონი'] = 'რეგიონი'
    ka_text['უბანი'] = 'უბანი'
    ka_text['ქვეყანა'] = 'ქვეყანა'
    
    ShapeTypeTranslation.transaction do 
      ShapeTypeTranslation.all.each do |trans|
        if trans.locale == 'en'
          trans.name_singular_in = 'in ' + trans.name_singular
        else
          trans.name_singular_in = ka_text[trans.name_singular]
        end
        trans.save      
      end
    end  
  end

  def down
    remove_column :shape_type_translations, :name_singular_in
  end
end
